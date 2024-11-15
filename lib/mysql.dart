  import 'package:mysql1/mysql1.dart';

  class Mysql {
    static String host = '34.143.206.185',
                  user = 'root',
                  password = 'alpha',
                  db = 'harlem';
    static int port = 3306;

    Mysql();

    Future<MySqlConnection> getConnection() async {
      var settings = new ConnectionSettings(
        host: host,
        port: port,
        user: user,
        password: password,
        db:db
      );
      return await MySqlConnection.connect(settings);
    }

      Future<List<String>> getClients() async {
    var conn = await getConnection();
    var results =
        await conn.query('SELECT name FROM harlem_client.client ORDER BY name');
    List<String> clients = [];
    for (var row in results) {
      clients.add(row[0]
          as String); // Assuming 'name' is the first column in the result
    }
    await conn.close();
    return clients;
  }

  Future<List<String>> getProducts() async {
    var conn = await getConnection();
    var results = await conn
        .query('SELECT name FROM harlem_products.product_main ORDER BY name');
    List<String> products = [];
    for (var row in results) {
      products.add(row[0]
          as String); // Assuming 'name' is the first column in the result
    }
    await conn.close();
    return products;
  }
  }