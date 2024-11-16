import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = '34.143.206.185',
      user = 'root',
      password = 'alpha',
      db = 'harlem';
  static int port = 3306;

  Mysql();

  // Create a single connection instance
  Future<MySqlConnection> getConnection() async {
    var settings = new ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: db,
    );
    return await MySqlConnection.connect(settings);
  }

  // Fetch user data based on ID
  Future<Map<String, dynamic>> getUserData(int userId) async {
    var conn = await getConnection();
    
    var results = await conn.query(
      'SELECT name, email, age FROM users WHERE id = ?',
      [userId],
    );

    Map<String, dynamic> userData = {};
    
    if (results.isNotEmpty) {
      var row = results.first;
      userData = {
        'name': row[0],
        'email': row[1],
        'age': row[2],
      };
    }

    await conn.close();
    return userData;
  }

  // Fetch all clients from the database
  Future<List<String>> getClients() async {
    var conn = await getConnection();
    var results = await conn.query(
        'SELECT name FROM harlem_client.client ORDER BY name');
    List<String> clients = [];
    for (var row in results) {
      clients.add(row[0] as String); // Assuming 'name' is the first column
    }
    await conn.close();
    return clients;
  }

  // Fetch all products from the database
  Future<List<String>> getProducts() async {
    var conn = await getConnection();
    var results = await conn.query(
        'SELECT name FROM harlem_products.product_main ORDER BY name');
    List<String> products = [];
    for (var row in results) {
      products.add(row[0] as String); // Assuming 'name' is the first column
    }
    await conn.close();
    return products;
  }

  // Fetch inventory data for a specific client and product
  Future<List<Map<String, dynamic>>> getInventoryForProductAndClient(
      String clientName, String productName) async {
    var conn = await getConnection();

    String query = '''SELECT i.id, p.name, DATE(i.receive_datetime), i.type 
    FROM harlem_inventory.inventory i
    LEFT JOIN harlem_products.product_main p ON p.id=i.product_id
    WHERE i.onhand_quantity_pcs > 0 
    AND i.receive = true 
    AND i.expiry_date > CURDATE() 
    AND i.product_id = (SELECT id FROM harlem_products.product_main WHERE name = '$productName')
    AND i.mainlocation_id = (SELECT id FROM harlem_inventory.mainlocation WHERE name = 'RGA')
    AND EXISTS (SELECT 1 FROM harlem_client.client c WHERE c.name = '$clientName')
    ORDER BY i.expiry_date, i.receive_datetime ''';

    try {
      print("Query String: $query");

      // Execute the query
      var results = await conn.query(query);

      List<Map<String, dynamic>> inventoryData = [];
      for (var row in results) {
        inventoryData.add({
          'id': row[0],
          'product_name': row[1],
          'receive_datetime': row[2],
          'type': row[3],
        });
      }

      await conn.close();
      return inventoryData;
    } catch (e) {
      print('Error fetching inventory: $e');
      await conn.close();
      return [];
    }
  }

   // Fetch detailed inventory data based on id and clientName
  Future<Map<String, dynamic>> getDetailedInventoryData(
      String inventoryId, String clientName) async {
    var conn = await getConnection();

    // SQL query for detailed inventory info
    String query =
        '''SELECT p.name, i.contents_box, i.expiry_date, pr.price_box, 
                      f.path, i.onhand_quantity_pcs, i.contents_case 
                      FROM harlem_inventory.inventory i
                      LEFT JOIN harlem_products.product_main p ON p.id = i.product_id
                      LEFT JOIN harlem_price.price pr ON pr.inventory_id = i.id
                      LEFT JOIN harlem_ftp.inventory f ON f.inventory_id = i.id
                      WHERE i.id = ? 
                      AND pr.class_id = (
                        SELECT class_id 
                        FROM harlem_client.client 
                        WHERE name = ? 
                      )''';

    try {
      var results = await conn.query(query, [inventoryId, clientName]);

      Map<String, dynamic> detailedData = {};

      if (results.isNotEmpty) {
        var row = results.first;
        detailedData = {
          'name': row[0], // Product name
          'contents_box': row[1], // Contents per box
          'expiry_date': row[2], // Expiry date
          'price_box': row[3], // Price per box
          'path': row[4], // FTP path
          'onhand_quantity_pcs': row[5], // On hand quantity in pcs
          'contents_case': row[6], // Contents per case
        };
      }

      await conn.close();
      return detailedData;
    } catch (e) {
      print('Error fetching detailed inventory data: $e');
      await conn.close();
      return {};
    }
  }


}
