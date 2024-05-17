import 'dart:convert';
import 'home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  final String searchQuery;

  SearchPage({required this.searchQuery});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> searchResults = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    // Call a method to fetch search results when the page is initialized
    print('Init state called');
    fetchSearchResults(widget.searchQuery);
  }

  Future<void> fetchSearchResults(String query) async {
    print('Fetching search results...');
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/search'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'query': query}),
      );

      if (response.statusCode == 200) {
        setState(() {
          searchResults = jsonDecode(response.body);
          isLoading = false; // Set loading to false when results are fetched
        });
      } else {
        print('Failed to fetch search results. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false; // Set loading to false in case of failure
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Set loading to false in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching results
          : ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          // Build search result items
        },
      ),
    );
  }
}
