import 'package:f_price_query/formatdate.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart'; // Required for MySQL operations
import 'mysql.dart'; // Import the Mysql class
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class PriceQuery extends StatefulWidget {
  @override
  _PriceQueryState createState() => _PriceQueryState();
}

class _PriceQueryState extends State<PriceQuery> {
  final Mysql mysql = Mysql(); // Instance of the Mysql class

  List<String> clientSuggestions = [];
  List<String> productSuggestions = [];
  bool isClientSelected = false;
  bool isSearchingProduct =
      false; // Track whether we are searching for a product
  String selectedClient = '';
  String selectedProduct = '';
  bool isSearching = false;
  String _searchQuery = '';
  String productLength = ''; // New property for storing product length

  // Controllers for autocomplete
  TextEditingController clientController = TextEditingController();
  TextEditingController productController = TextEditingController();

  // Fetch clients and products from the database
  Future<void> fetchClientsAndProducts() async {
    try {
      var fetchedClients = await mysql.getClients();
      var fetchedProducts = await mysql.getProducts();
      setState(() {
        clientSuggestions = fetchedClients;
        productSuggestions = fetchedProducts;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClientsAndProducts(); // Fetch clients and products when the page loads
  }

  // Function to handle searching and sorting
  Future<List<String>> _fetchFilteredNames(
      String query, List<String> suggestions) async {
    return suggestions.where((String option) {
      return option.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Fetch inventory data based on the selected client and product
  Future<List<Map<String, dynamic>>> fetchInventoryData(
      String client, String product) async {
    try {
      // Assuming you have a method in Mysql.dart to query inventory by client and product
      var inventoryData =
          await mysql.getInventoryForProductAndClient(client, product);
      return inventoryData;
    } catch (e) {
      print('Error fetching inventory: $e');
      return []; // Return empty list if an error occurs
    }
  }

 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(
            5.0), // Reduced padding for overall compactness
        child: SingleChildScrollView(
          // Wrap the entire body in a SingleChildScrollView
          child: Column(
            children: [
              // Client InputDecorator with Autocomplete Search
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Client', // Label for the Client section
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!isClientSelected) {
                                setState(() {
                                  // Allow searching again if the client is not selected
                                  isSearching = true;
                                  _searchQuery = '';
                                });
                              }
                            },
                            child: AbsorbPointer(
                              absorbing:
                                  isClientSelected, // Disable search if client is selected
                              child: Opacity(
                                opacity: isClientSelected
                                    ? 0.5
                                    : 1.0, // Adjust opacity if client is selected
                                child: isSearching
                                    ? Autocomplete<String>(
                                        optionsBuilder: (TextEditingValue
                                            textEditingValue) async {
                                          if (textEditingValue.text.isEmpty) {
                                            return const Iterable<
                                                String>.empty();
                                          }

                                          final filteredNames =
                                              await _fetchFilteredNames(
                                                  textEditingValue.text,
                                                  clientSuggestions);
                                          final query = textEditingValue.text
                                              .toLowerCase();
                                          final suggestions =
                                              filteredNames.where((name) {
                                            final nameLower =
                                                name.toLowerCase();
                                            return nameLower
                                                    .startsWith(query) ||
                                                nameLower.contains(query);
                                          }).toList();

                                          suggestions.sort((a, b) {
                                            final aLower = a.toLowerCase();
                                            final bLower = b.toLowerCase();
                                            if (aLower.startsWith(query) &&
                                                !bLower.startsWith(query)) {
                                              return -1;
                                            } else if (!aLower
                                                    .startsWith(query) &&
                                                bLower.startsWith(query)) {
                                              return 1;
                                            }
                                            return aLower.compareTo(bLower);
                                          });

                                          return suggestions;
                                        },
                                        displayStringForOption:
                                            (String option) => option,
                                        fieldViewBuilder: (context, controller,
                                            focusNode, onFieldSubmitted) {
                                          return TextField(
                                            controller: controller,
                                            focusNode: focusNode,
                                            decoration: InputDecoration(
                                              hintText: 'Search Client...',
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                            ),
                                          );
                                        },
                                        onSelected: (String selection) {
                                          setState(() {
                                            selectedClient = selection;
                                            isClientSelected =
                                                true; // Mark client as selected
                                            isSearching =
                                                false; // Stop searching once selected
                                          });
                                        },
                                      )
                                    : Row(
                                        children: [
                                          Icon(Icons.search,
                                              color: Colors.black, size: 30),
                                          SizedBox(width: 8),
                                          Text(
                                            selectedClient.isEmpty
                                                ? ''
                                                : selectedClient,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              clientController.clear();
                              selectedClient = '';
                              isClientSelected =
                                  false; // Reset client selection
                              isSearching = false; // Reset search state
                              selectedProduct = '';
                            });
                          },
                          icon: Icon(Icons.refresh_sharp, color: Colors.black),
                          iconSize: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Product Container with Autocomplete Search (same as client)
              AbsorbPointer(
                absorbing:
                    !isClientSelected, // Disable interaction if client is not selected
                child: Opacity(
                  opacity: isClientSelected
                      ? 1.0
                      : 0.5, // Dim the product search if client is not selected
                  child: Tooltip(
                    message: isClientSelected
                        ? ""
                        : "Please select a client first", // Tooltip for user guidance
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Product', // Label for the Client section
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSearchingProduct =
                                          true; // Start searching for product
                                    });
                                  },
                                  child: isSearchingProduct
                                      ? Autocomplete<String>(
                                          optionsBuilder: (TextEditingValue
                                              textEditingValue) async {
                                            if (textEditingValue.text.isEmpty) {
                                              return const Iterable<
                                                  String>.empty();
                                            }

                                            final filteredNames =
                                                await _fetchFilteredNames(
                                                    textEditingValue.text,
                                                    productSuggestions);
                                            final query = textEditingValue.text
                                                .toLowerCase();
                                            final suggestions =
                                                filteredNames.where((name) {
                                              final nameLower =
                                                  name.toLowerCase();
                                              return nameLower
                                                      .startsWith(query) ||
                                                  nameLower.contains(query);
                                            }).toList();

                                            suggestions.sort((a, b) {
                                              final aLower = a.toLowerCase();
                                              final bLower = b.toLowerCase();
                                              if (aLower.startsWith(query) &&
                                                  !bLower.startsWith(query)) {
                                                return -1;
                                              } else if (!aLower
                                                      .startsWith(query) &&
                                                  bLower.startsWith(query)) {
                                                return 1;
                                              }
                                              return aLower.compareTo(bLower);
                                            });

                                            return suggestions;
                                          },
                                          displayStringForOption:
                                              (String option) => option,
                                          fieldViewBuilder: (context,
                                              controller,
                                              focusNode,
                                              onFieldSubmitted) {
                                            return TextField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              decoration: InputDecoration(
                                                hintText: 'Search Product...',
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                              ),
                                            );
                                          },
                                          onSelected: (String selection) {
                                            setState(() {
                                              selectedProduct = selection;
                                              isSearchingProduct =
                                                  false; // Stop searching after selection
                                              productLength =
                                                  "Length: ${selection.length}";
                                            });
                                          },
                                        )
                                      : Row(
                                          children: [
                                            Icon(Icons.search,
                                                color: Colors.black, size: 30),
                                            SizedBox(width: 8),
                                            Text(
                                              selectedProduct.isEmpty
                                                  ? ''
                                                  : selectedProduct,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (selectedProduct.isNotEmpty) {
                                    print(
                                        'Showing Old Price for: $selectedProduct');
                                  }
                                },
                                child: Text('Old Price',
                                    style: TextStyle(fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey
                                      .shade300, // Light gray for secondary action
                                  foregroundColor: Colors.black, // Text color
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(),

              // Inventory section only shown after selecting both client and product
              AbsorbPointer(
  absorbing: !(isClientSelected && selectedProduct.isNotEmpty),
  child: Opacity(
    opacity: (isClientSelected && selectedProduct.isNotEmpty) ? 1.0 : 0.5,
    child: Tooltip(
      message: (isClientSelected && selectedProduct.isNotEmpty)
          ? ""
          : "Please select both a client and product",
      child: SingleChildScrollView(
        // Make the entire content scrollable
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding around the InputDecorator
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Inventory',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: selectedProduct.isNotEmpty
                ? FutureBuilder<List<Map<String, dynamic>>>( 
                    future: fetchInventoryData(selectedClient, selectedProduct),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error fetching inventory data.'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No inventory found.'));
                      }

                      var inventoryItems = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true, // Make the ListView shrinkable
                        physics: NeverScrollableScrollPhysics(), // Prevent ListView from scrolling itself
                        itemCount: inventoryItems.length,
                        itemBuilder: (context, index) {
                          var item = inventoryItems[index];

                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ExpansionTile(
                              title: Text(
                                item['product_name'], // Product Name
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                              leading: Icon(Icons.inventory, color: Colors.blue),
                              onExpansionChanged: (expanded) async {
                                if (expanded) {
                                  print('Tile is opened: ${item['product_name']}');

                                  // Get detailed inventory data when expanded
                                  var inventoryId = item['id']; // Assuming you have an 'inventory_id'
                                  var clientName = selectedClient; // Using the selected client name
                                  
                                  // Fetch detailed data
                                  var detailedData = await mysql.getDetailedInventoryData(inventoryId, clientName);

                                  if (detailedData.isNotEmpty) {
                                    print('Detailed inventory data for ${item['product_name']}:');
                                    print(detailedData);
                                  } else {
                                    print('No detailed data found.');
                                  }
                                  // Optionally, display this information in the UI (e.g., in a dialog or a bottom sheet)
                                  // For example, showing the SQL query result in a simple dialog:
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Detailed Inventory Data'),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Product: ${detailedData['name'] ?? 'N/A'}'),
                                              Text('Contents Box: ${detailedData['contents_box'] ?? 'N/A'}'),
                                              Text('Expiry Date: ${detailedData['expiry_date'] ?? 'N/A'}'),
                                              Text('Price Box: ${detailedData['price_box'] ?? 'N/A'}'),
                                              Text('FTP Path: ${detailedData['path'] ?? 'N/A'}'),
                                              Text('On-hand Quantity (pcs): ${detailedData['onhand_quantity_pcs'] ?? 'N/A'}'),
                                              Text('Contents per Case: ${detailedData['contents_case'] ?? 'N/A'}'),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text('Close'),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  print('Tile is closed: ${item['product_name']}');
                                }
                              },
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Received on: ${formatDate(item['receive_datetime'])}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Type: ${item['type']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 6),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'Select a product to see inventory.',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
          ),
        ),
      ),
    ),
  ),
)



            ],
          ),
        ),
      ),
    );
  }

}
