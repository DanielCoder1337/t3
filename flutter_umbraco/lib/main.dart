import 'dart:convert';
import 'dart:io';
import 'dart:js';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode)
      exit(1);
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Product {
  final String name;
  final int id;
  final List<dynamic> category;
  final String description;
  final double price;
  final String imageUrl;

  Product({this.name, this.id, this.category, this.description, this.price, this.imageUrl});

  factory Product.fromJson(json) {
    return Product(
      name: json['Name'],
      id: json['Id'],
      category: json['Category'],
      description: json["Description"],
      price: json["Price"],
      imageUrl: json["ImageUrl"]
    );
  }
}

Future<List<Product>> fetchProducts() async {
  final response = await http.get('http://localhost:7294/Umbraco/Api/Products/GetAllProducts');
  final List<Product> list = [];

  if (response.statusCode == 200) {
    final jsonDec = jsonDecode(response.body);
    for (var product in jsonDec) {
      list.add(Product.fromJson(product));
    }
    return list;
  } else {
    throw Exception('Failed to load album');
  }
}

Future<List<People>> fetchPeople() async {
  final response = await http.get('http://localhost:7294/Umbraco/Api/People/GetAllPeople');
  final List<People> list = [];

  if (response.statusCode == 200) {
    final jsonDec = jsonDecode(response.body);
    for (var person in jsonDec) {
      list.add(People.fromJson(person));
    }
    return list;
  } else {
    throw Exception('Failed to load album');
  }
}

class ListDisplay extends StatefulWidget {
  @override
  State createState() => new DyanmicList();
}

class DyanmicList extends State<ListDisplay> {
  Future<List<Product>> litems = fetchProducts();
  @override
  
  Widget build (BuildContext ctxt) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Text("Products"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pop(ctxt);
            },
          )
        ],
      ),
      body: Center(
        child: 
          FutureBuilder<List<Product>>(
            future: litems,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Product> products = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    Product product = products[index];
                    return new Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                           ListTile(
                            leading: CircleAvatar(radius: 26.0,backgroundImage: NetworkImage(product.imageUrl),),
                            title: Text(product.name,style: TextStyle(fontSize: 30.0),),
                            subtitle: Text(product.description,style: TextStyle(fontSize: 14.0),),
                          ),
                          ButtonBar(
                            children: <Widget>[
                              FlatButton(
                                child: const Text('VIEW'),
                                onPressed: () { Navigator.push(context, MaterialPageRoute( builder: (context) => ProductsDetailViewState(product: product))); },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          ),
      ),
    );
  }
}

class ProductsDetailViewState extends StatelessWidget {
  final Product product;

  // In the constructor, require a Todo.
  ProductsDetailViewState({Key key, @required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(product.description),
      ),
    );
  }
}

class PeopleDetailView extends StatelessWidget {
  final People person;

  // In the constructor, require a Todo.
  PeopleDetailView({Key key, @required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(person.email),
      ),
    );
  }
}

class People {
  final String name;
  final int id;
  final String email;
  final String twitter;
  final String facebook;
  final String linkedIn;
  final String instagram;
  final String imageUrl;


  People({this.name, this.id, this.email,this.twitter, this.facebook, this.linkedIn, this.instagram, this.imageUrl});

  factory People.fromJson(json) {
    return People(
      name: json['Name'],
      id: json['Id'],
      email: json["Email"],
      twitter: json['Twitter_username'],
      facebook: json["Facebook_username"],
      linkedIn: json["LinkedIn_username"],
      instagram: json["Instagram_username"],
      imageUrl: json["ImageUrl"]
    );
  }
}


class PeopleListView extends StatelessWidget {
  // In the constructor, require a Todo.
  PeopleListView({Key key}) : super(key: key);
  final peopleList = fetchPeople();
  @override
  Widget build (BuildContext ctxt) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Text("People"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pop(ctxt);
            },
          )
        ],
      ),
      body: Center(
        child: 
          FutureBuilder<List<People>>(
            future: peopleList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<People> people = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: people.length,
                  itemBuilder: (context, index) {
                    People person = people[index];
                    return new Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                           ListTile(
                            leading: CircleAvatar(radius: 26.0,backgroundImage: NetworkImage(person.imageUrl),),
                            title: Text(person.name,style: TextStyle(fontSize: 30.0),),
                            subtitle: Text(person.email,style: TextStyle(fontSize: 14.0),),
                          ),
                          ButtonBar(
                            children: <Widget>[
                              FlatButton(
                                child: const Text('VIEW'),
                                onPressed: () { Navigator.push(context, MaterialPageRoute( builder: (context) => PeopleDetailView(person: person))); },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key,}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Text("Home"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shop),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListDisplay()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PeopleListView()),
              );
            },
          )
        ],
      ),
      body:
      new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(image: new AssetImage("images/umbracoLivingRoom.png"), fit: BoxFit.cover,),
            ),
          ),
          Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome to this umbraco based site!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 36.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 10.0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.teal,
                      child: Text("PRODUCTS"),
                      onPressed: () {Navigator.push(context, MaterialPageRoute( builder: (context) => ListDisplay()));},
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ],
              ),
          ),
        ],
      )
    );
  }
}
