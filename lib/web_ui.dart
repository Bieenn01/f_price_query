import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Sample data for autocomplete suggestions
  final List<String> clientSuggestions = [
    'Client A',
    'Client B',
    'Client C',
    'Client D'
  ];
  final List<String> productSuggestions = [
    'Product 1',
    'Product 2',
    'Product 3',
    'Product 4'
  ];

  // Controllers for autocomplete
  TextEditingController clientController = TextEditingController();
  TextEditingController productController = TextEditingController();

  String selectedClient = '';
  String selectedProduct = '';
  bool isClientSelected = false; // Flag to track client selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Price Query', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.search, color: Colors.white),
        //     onPressed: () {
        //       // Implement search functionality or show search bar
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Client Container with Autocomplete Search
            Container(
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Client',
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.black),
                      SizedBox(width: 8),
                      Expanded(
                        child: Autocomplete<String>(
                          // Provide an initial value
                          initialValue: TextEditingValue(text: selectedClient),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return [];
                            }
                            return clientSuggestions.where((String option) {
                              return option.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase());
                            }).toList();
                          },
                          onSelected: (String selection) {
                            setState(() {
                              selectedClient = selection;
                              isClientSelected =
                                  true; // Mark client as selected
                            });
                            print('Selected Client: $selection');
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Enter and Reset buttons for Client
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (selectedClient.isNotEmpty) {
                            setState(() {
                              isClientSelected =
                                  true; // Ensure client is selected
                            });
                            print('Client entered: $selectedClient');
                          }
                        },
                        child: Text('Enter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // main action color
                          foregroundColor: Colors.white, // text color
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            clientController.clear();
                            selectedClient = '';
                            isClientSelected = false; // Reset client selection
                          });
                        },
                        child: Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.grey.shade300, // light gray for reset
                          foregroundColor: Colors.black, // text color
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Product Container with Autocomplete Search
            // This container will only be enabled if a client is selected
            if (isClientSelected) // Only show this container if client is selected
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Product',
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.black),
                        SizedBox(width: 8),
                        Expanded(
                          child: Autocomplete<String>(
                            // Provide an initial value for product selection
                            initialValue:
                                TextEditingValue(text: selectedProduct),
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return [];
                              }
                              return productSuggestions.where((String option) {
                                return option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase());
                              }).toList();
                            },
                            onSelected: (String selection) {
                              setState(() {
                                selectedProduct = selection;
                              });
                              print('Selected Product: $selection');
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Search and Old Price buttons for Product
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (selectedProduct.isNotEmpty) {
                              print('Searching for Product: $selectedProduct');
                            }
                          },
                          child: Text('Search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // main action color
                            foregroundColor: Colors.white, // text color
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedProduct.isNotEmpty) {
                              print('Showing Old Price for: $selectedProduct');
                            }
                          },
                          child: Text('Old Price'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey
                                .shade300, // light gray for secondary action
                            foregroundColor: Colors.black, // text color
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (isClientSelected)
              // Inventory Container (Blank)
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                height: 150, // Just to make the container visible
                child: Center(
                  child: Text('Inventory (Blank)',
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
