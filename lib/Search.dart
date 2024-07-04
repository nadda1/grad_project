import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:grad_project/specificjob.dart';

class SearchPage extends StatefulWidget {
  final String searchQuery;

  SearchPage({required this.searchQuery});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> searchResults = [];
  bool isLoading = true; // Track loading state
  int currentPage = 1;
  int totalPages = 1; // Track total number of pages

  // Controller and FocusNode for the search bar
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize search bar with initial query
    _searchController.text = widget.searchQuery;
    // Call a method to fetch search results when the page is initialized
    fetchSearchResults(widget.searchQuery, currentPage);
  }

  Future<void> fetchSearchResults(String query, int page) async {
    print('Fetching search results for page $page...');
    try {
      final response = await http.post(
        Uri.parse('https://snapwork-flask.azurewebsites.net/search?page=$page'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'query': query}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> searchJobs = jsonResponse['search_jobs'];
        final int totalResults = searchJobs.length;

        setState(() {
          searchResults = searchJobs;
          totalPages = (totalResults / 10).ceil(); // Calculate total pages
          isLoading = false; // Set loading to false when results are fetched
        });
      } else {
        print(
            'Failed to fetch search results. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false; // Set loading to false in case of failure
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
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
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                // Perform search when the user submits
                setState(() {
                  currentPage = 1; // Reset page to 1
                  isLoading = true; // Set loading state
                });
                fetchSearchResults(value, currentPage);
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Perform search when the search icon is pressed
                    setState(() {
                      currentPage = 1; // Reset page to 1
                      isLoading = true; // Set loading state
                    });
                    fetchSearchResults(
                        _searchController.text, currentPage);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final job = searchResults[index];
                final formattedDate = ''; // Format your date here
                final distance = ''; // Calculate distance here
                final message = ''; // Determine message here
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpecificJobPage(
                          jobId: job['id'].toString(),
                          specializationId:
                          job['specialization']?['id']?.toString() ??
                              '1',
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              job['title'],
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF343ABA),
                              ),
                            ),
                          ),
                          SizedBox(width: 30), // Spacer
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['description'],
                            style: TextStyle(color: Colors.black87),
                          ),
                          Text(
                            'Created at: $formattedDate',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Distance: $distance',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            message,
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: Text(
                        'Budget: ${job['expected_budget']} \$',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (currentPage !=
                    1) // Only show if not on the first page
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentPage -= 1;
                        isLoading = true;
                      });
                      fetchSearchResults(
                          _searchController.text, currentPage);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: Icon(Icons.arrow_back),
                  ),
                SizedBox(width: 10), // Add some space between buttons
                ...List.generate(
                  totalPages,
                      (index) => ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentPage += 1;
                        isLoading = true;
                      });
                      fetchSearchResults(
                          _searchController.text, currentPage);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPage == index + 1
                          ? Colors.blue
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
