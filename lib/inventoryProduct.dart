import 'package:f_price_query/formatdate.dart';
import 'package:f_price_query/sql/mysql_services.dart';
import 'package:flutter/material.dart';

class InventoryDetailCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final String selectedClient;
  final Function(Map<String, dynamic>) onDetailDataFetched;

  const InventoryDetailCard({
    Key? key,
    required this.item,
    required this.selectedClient,
    required this.onDetailDataFetched,
  }) : super(key: key);

  @override
  _InventoryDetailCardState createState() => _InventoryDetailCardState();
}

class _InventoryDetailCardState extends State<InventoryDetailCard> {
  final MysqlService mysql = MysqlService();
  bool _isFetchingDetailedData = false;

  @override
  void initState() {
    super.initState();
    // Preload data when expanded for the first time
  }

  Future<void> _fetchDetailedData() async {
    if (widget.item['detailedData'] == null && !_isFetchingDetailedData) {
      setState(() {
        _isFetchingDetailedData = true;
      });

      var inventoryId = widget.item['id'];
      var clientName = widget.selectedClient;
      var detailedData =
          await mysql.getDetailedInventoryData(inventoryId, clientName);

      if (detailedData.isNotEmpty) {
        setState(() {
          widget.item['detailedData'] = detailedData;
        });
        widget.onDetailDataFetched(detailedData);
      }

      setState(() {
        _isFetchingDetailedData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          widget.item['product_name'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        leading: Icon(Icons.inventory, color: Colors.blue),
        onExpansionChanged: (expanded) {
          if (expanded) {
            _fetchDetailedData();
          }
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Received on: ${formatDate(widget.item['receive_datetime'])}'),
                SizedBox(height: 8),
                Text('Type: ${widget.item['type']}'),
                SizedBox(height: 8),
                if (_isFetchingDetailedData)
                  Center(child: CircularProgressIndicator())
                else if (widget.item['detailedData'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Detailed Inventory Data:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                          'Product: ${widget.item['detailedData']['name'] ?? 'N/A'}'),
                      Text(
                          'Contents Box: ${widget.item['detailedData']['contents_box'] ?? 'N/A'}'),
                      Text(
                        'Expiry Date: ${widget.item['detailedData']['expiry_date'] != null ? formatDate(widget.item['detailedData']['expiry_date']) : 'N/A'}',
                      ),
                      Text(
                          'Price Box: ${widget.item['detailedData']['price_box'] ?? 'N/A'}'),
                      Text(
                          'FTP Path: ${widget.item['detailedData']['path'] ?? 'N/A'}'),
                      Text(
                          'On-hand Quantity (pcs): ${widget.item['detailedData']['onhand_quantity_pcs'] ?? 'N/A'}'),
                      Text(
                          'Contents per Case: ${widget.item['detailedData']['contents_case'] ?? 'N/A'}'),
                    ],
                  )
                else
                  Text('No detailed data available.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
