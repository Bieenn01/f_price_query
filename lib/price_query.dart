import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart'; // Required for MySQL operations
import 'mysql.dart'; // Import the Mysql class

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(
            5.0), // Reduced padding for overall compactness
        child: Column(
          children: [
            // Client Container with Autocomplete Search
            Container(
              padding: EdgeInsets.all(12.0), // Reduced padding
              margin: EdgeInsets.symmetric(
                  vertical: 25.0), // Reduced vertical margin
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
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
                            setState(() {
                              // Allow searching again if the client is selected
                              isSearching = true;
                              _searchQuery = '';
                            });
                          },
                          child: isSearching
                              ? Autocomplete<String>(
                                  optionsBuilder: (TextEditingValue
                                      textEditingValue) async {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<String>.empty();
                                    }

                                    final filteredNames =
                                        await _fetchFilteredNames(
                                            textEditingValue.text,
                                            clientSuggestions);
                                    final query =
                                        textEditingValue.text.toLowerCase();
                                    final suggestions =
                                        filteredNames.where((name) {
                                      final nameLower = name.toLowerCase();
                                      return nameLower.startsWith(query) ||
                                          nameLower.contains(query);
                                    }).toList();

                                    suggestions.sort((a, b) {
                                      final aLower = a.toLowerCase();
                                      final bLower = b.toLowerCase();
                                      if (aLower.startsWith(query) &&
                                          !bLower.startsWith(query)) {
                                        return -1;
                                      } else if (!aLower.startsWith(query) &&
                                          bLower.startsWith(query)) {
                                        return 1;
                                      }
                                      return aLower.compareTo(bLower);
                                    });

                                    return suggestions;
                                  },
                                  displayStringForOption: (String option) =>
                                      option,
                                  fieldViewBuilder: (context, controller,
                                      focusNode, onFieldSubmitted) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: InputDecoration(
                                        hintText: 'Search Client...',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
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
                      IconButton(
                        onPressed: () {
                          setState(() {
                            clientController.clear();
                            selectedClient = '';
                            isClientSelected = false; // Reset client selection
                            isSearching = false; // Reset search state
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
                  child: Container(
                    padding: EdgeInsets.all(12.0), // Reduced padding
                    margin: EdgeInsets.symmetric(
                        vertical: 8.0), // Reduced vertical margin
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
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
                                        fieldViewBuilder: (context, controller,
                                            focusNode, onFieldSubmitted) {
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

            // Inventory section only shown after selecting both client and product
            AbsorbPointer(
              absorbing: !(isClientSelected && selectedProduct.isNotEmpty),
              child: Opacity(
                opacity: (isClientSelected && selectedProduct.isNotEmpty)
                    ? 1.0
                    : 0.5,
                child: Tooltip(
                  message: (isClientSelected && selectedProduct.isNotEmpty)
                      ? ""
                      : "Please select both a client and product",
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    height: 120,
                    child: selectedProduct.isNotEmpty
                        ? Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading:
                                  Icon(Icons.inventory, color: Colors.blue),
                              title: Text(
                                selectedProduct,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Length: ${selectedProduct.length} characters',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              'Inventory (Blank)',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
