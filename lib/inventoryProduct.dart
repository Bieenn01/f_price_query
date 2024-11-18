import 'package:f_price_query/formatdate.dart';
import 'package:f_price_query/sql/mysql_services.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart'; // Required for MySQL operations
import 'sql/mysql.dart'; // Import the Mysql class

class InventoryExpansionTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final String selectedClient;
  final Function(Map<String, dynamic>) onDetailDataFetched;

  const InventoryExpansionTile({
    Key? key,
    required this.item,
    required this.selectedClient,
    required this.onDetailDataFetched,
  }) : super(key: key);

  @override
  _InventoryExpansionTileState createState() => _InventoryExpansionTileState();
}

class _InventoryExpansionTileState extends State<InventoryExpansionTile> {
  final MysqlService mysql = MysqlService();
  bool _isFetchingDetailedData = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          widget.item['product_name'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
        ),
        leading: Icon(Icons.inventory, color: Colors.blue),
        onExpansionChanged: (expanded) async {
          if (expanded && widget.item['detailedData'] == null && !_isFetchingDetailedData) {
            setState(() {
              _isFetchingDetailedData = true;
            });

            // Fetch detailed data only if not already fetched
            var inventoryId = widget.item['id'];
            var clientName = widget.selectedClient;
            var detailedData = await mysql.getDetailedInventoryData(inventoryId, clientName);

            if (detailedData.isNotEmpty) {
              widget.item['detailedData'] = detailedData;  // Store detailed data in the item

              // Call callback to notify parent that data was fetched
              widget.onDetailDataFetched(detailedData);
            }
            setState(() {
              _isFetchingDetailedData = false;
            });
          }
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Received on: ${formatDate(widget.item['receive_datetime'])}'),
                SizedBox(height: 6),
                Text('Type: ${widget.item['type']}'),
                SizedBox(height: 6),
                // Check if detailed data is available and display it
                if (widget.item['detailedData'] != null) ...[
                  ExpansionTile(
                    title: Text('Detailed Inventory Data', style: TextStyle(fontWeight: FontWeight.bold)),
                    leading: Icon(Icons.info_outline, color: Colors.blue),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Product: ${widget.item['detailedData']['name'] ?? 'N/A'}'),
                            Text('Contents Box: ${widget.item['detailedData']['contents_box'] ?? 'N/A'}'),
                            Text('Expiry Date: ${widget.item['detailedData']['expiry_date'] ?? 'N/A'}'),
                            Text('Price Box: ${widget.item['detailedData']['price_box'] ?? 'N/A'}'),
                            Text('FTP Path: ${widget.item['detailedData']['path'] ?? 'N/A'}'),
                            Text('On-hand Quantity (pcs): ${widget.item['detailedData']['onhand_quantity_pcs'] ?? 'N/A'}'),
                            Text('Contents per Case: ${widget.item['detailedData']['contents_case'] ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ]
            ],
          ),
        ),
      ],
      )
    );
  }

  Future<void> _fetchDetailedData(Map<String, dynamic> item) async {
    var inventoryId = item['id'];
    var clientName = widget.selectedClient;

    // Only fetch detailed data if it's not cached
    if (item['detailedData'] == null) {
      var detailedData =
          await mysql.getDetailedInventoryData(inventoryId, clientName);
      if (detailedData.isNotEmpty) {
        setState(() {
          item['detailedData'] = detailedData;
        });
        widget.onDetailDataFetched(detailedData);
      }
    }
  }
}
