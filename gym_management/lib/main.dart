import 'package:flutter/material.dart';
import 'member.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 51, 55, 62)),
      ),
      home: const MyHomePage(title: 'Gym management system'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  TextEditingController name = TextEditingController();
  TextEditingController age = TextEditingController();
  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 24),
              Image.asset(
                'assets/images/logo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RegistrationForm()));
                },
                child: Text("Register New Member")
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MemberScreen()));
                },
                child: Text("Get Members details")
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>FeeScreen()));
                },
                child: Text("Fees Management")
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// Simple placeholder screens for navigation
class MemberScreen extends StatefulWidget {
  @override
  _MemberScreenState createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  List<MemberModel> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final members = await MemberStorage.loadMembers();
    setState(() {
      _members = members;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Member Details')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? Center(child: Text('No members found.'))
              : ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final m = _members[index];
                      return ListTile(
                        title: Text(m.name),
                        subtitle: Text('Contact: ${m.contact}\nPlan: ${m.plan}\nFee Status: ${m.fee.paid ? 'Paid' : 'Pending'}'),
                        isThreeLine: true,
                      );
                  },
                ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _planController = TextEditingController();

  bool _saving = false;
  String? _message;
  String _feeStatus = 'Paid';

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _message = null; });
    final members = await MemberStorage.loadMembers();
    final newMember = MemberModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      contact: _contactController.text,
      plan: _planController.text,
      attendance: [],
      fee: Fee(amount: 0, dueDate: '', paid: _feeStatus == 'Paid', history: []),
    );
    members.add(newMember);
    await MemberStorage.saveMembers(members);
    setState(() {
      _saving = false;
      _message = 'Member registered!';
      _nameController.clear();
      _contactController.clear();
      _planController.clear();
      _feeStatus = 'Paid';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Member')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Contact'),
                validator: (v) => v == null || v.isEmpty ? 'Enter contact' : null,
              ),
              TextFormField(
                controller: _planController,
                decoration: InputDecoration(labelText: 'Plan'),
                validator: (v) => v == null || v.isEmpty ? 'Enter plan' : null,
              ),


              // In the registration form's children:
              DropdownButtonFormField<String>(
                value: _feeStatus,
                decoration: InputDecoration(labelText: 'Fee Status'),
                items: ['Paid', 'Pending']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _feeStatus = val);
                },
              ),

//
              SizedBox(height: 20),
              _saving
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveMember,
                      child: Text('Register'),
                    ),
              if (_message != null) ...[
                SizedBox(height: 16),
                Text(_message!, style: TextStyle(color: Colors.green)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class FeeScreen extends StatefulWidget {
  @override
  _FeeScreenState createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  List<MemberModel> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final members = await MemberStorage.loadMembers();
    setState(() {
      _members = members;
      _loading = false;
    });
  }

  Future<void> _editFeeStatus(int index) async {
    String newStatus = _members[index].fee.paid ? 'Paid' : 'Pending';
    String dueDate = _members[index].fee.dueDate;
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        TextEditingController dateController = TextEditingController(text: dueDate);
        return AlertDialog(
          title: Text('Edit Fee Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: newStatus,
                items: ['Paid', 'Pending']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) newStatus = val;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Due Date'),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate.isNotEmpty ? DateTime.tryParse(dueDate) ?? DateTime.now() : DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dateController.text = picked.toIso8601String().split('T')[0];
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'status': newStatus,
                'dueDate': dateController.text,
              }),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        _members[index].fee.paid = result['status'] == 'Paid';
        _members[index].fee.dueDate = result['dueDate'] ?? '';
      });
      await MemberStorage.saveMembers(_members);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fee Details')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? Center(child: Text('No members found.'))
              : ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final m = _members[index];
                    return ListTile(
                      title: Text(m.name),
                      subtitle: Text('Fee Status: ${m.fee.paid ? 'Paid' : 'Pending'}\nDue Date: ${m.fee.dueDate.isNotEmpty ? m.fee.dueDate : 'Not set'}'),
                      trailing: Icon(Icons.edit),
                      onTap: () => _editFeeStatus(index),
                    );
                  },
                ),
    );
  }
}
