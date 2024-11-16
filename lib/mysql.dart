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

    var results = await conn.query(
      '''
    SELECT i.id, p.name, DATE(i.receive_datetime), i.type 
    FROM harlem_inventory.inventory i
    LEFT JOIN harlem_products.product_main p ON p.id=i.product_id
    WHERE i.onhand_quantity_pcs > 0 
    AND i.receive = true 
    AND i.expiry_date > CURDATE() 
    AND i.product_id = (SELECT id FROM harlem_products.product_main WHERE name = ?)
    AND i.mainlocation_id = (SELECT id FROM harlem_inventory.mainlocation WHERE name = 'RGA')
    AND EXISTS (SELECT 1 FROM harlem_client.client c WHERE c.name = ?)
    ORDER BY i.expiry_date, i.receive_datetime
    ''',
      [productName, clientName],
    );

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
  }

}
