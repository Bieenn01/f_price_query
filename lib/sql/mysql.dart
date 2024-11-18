import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = '34.143.206.185',
      user = 'root',
      password = 'alpha',
      db = 'harlem';
  static int port = 3306;

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
}
