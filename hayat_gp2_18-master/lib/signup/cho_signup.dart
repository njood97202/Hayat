import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';
import 'package:hayat_gp2_18/signin/signin_all.dart';
import 'package:hayat_gp2_18/signin/cho_signin.dart';
import 'package:hayat_gp2_18/main.dart';
import 'package:hayat_gp2_18/home_pages/cho_home.dart';
import 'package:encrypt/encrypt.dart';
import 'package:hayat_gp2_18/encryption.dart';
import 'package:hayat_gp2_18/database/sqlite.dart';
import 'package:parse_server_sdk_flutter/generated/i18n.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

var selecteditem = null;

class SignupPage extends StatefulWidget {
  const SignupPage() : super();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>(); //key for form
  var response;
  late String e_mail;
  var pass;
  late String name;
  late int phone;
  late String location = "";
  late String x = '';

  var encryptedPass;
  var _LicenseNo;

  var allDonorswithEmail = [];
  var elements = [];
  var allDonorswithEmail2 = [];
  var elements2 = [];
  var LNum = [600, 14, 733, 668];

  var emailController = new TextEditingController();
  var passController = new TextEditingController();
  var nameController = new TextEditingController();
  var phoneController = new TextEditingController();
  var lNumberController = new TextEditingController();

  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNumber = false;
  bool _hasCapitalCharacter = false;
  bool _hasLowerCaseCharacter = false;
  bool _hasSpecialCharacter = false;

  onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');
    final capitalRegex = RegExp(r'[A-Z]');
    final lowerCaseRegex = RegExp(r'[a-z]');
    final specialCharRegex = RegExp(r'[#?!@$%^&*-]');

    setState(() {
      _isPasswordEightCharacters = false;
      if (password.length >= 8) _isPasswordEightCharacters = true;

      _hasPasswordOneNumber = false;
      if (numericRegex.hasMatch(password)) _hasPasswordOneNumber = true;

      _hasCapitalCharacter = false;
      if (capitalRegex.hasMatch(password)) _hasCapitalCharacter = true;

      _hasLowerCaseCharacter = false;
      if (lowerCaseRegex.hasMatch(password)) _hasLowerCaseCharacter = true;

      _hasSpecialCharacter = false;
      if (specialCharRegex.hasMatch(password)) _hasSpecialCharacter = true;
    });
  }

////database cloud add donor functions//////

  void addCHO() async {
    final donor =
        ParseUser(emailController.text, encryptedPass, emailController.text)
          ..set('location', location)
          ..set('phone', phone)
          ..set('lNumber', _LicenseNo)
          ..set('userType', 'cho')
          ..set('name', name);

    response = await donor.signUp();

    if (response.success) {
      Widget okButton = TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.pop(context, 'OK');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginChoPage()),
          );
        },
      );
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Success!"),
        content: Text("Account signed up successfully!"),
        actions: [
          okButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else if (response.success == false) {
      Widget okButton = TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.pop(context, 'OK');
        },
      );
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Error!"),
        content: Text("Account already exists for this email!"),
        actions: [
          okButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal[200],
        title: Text('Hayat food donation'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: formKey,
            //padding: EdgeInsets.symmetric(horizontal: 40),
            //height: MediaQuery.of(context).size.height - 50,
            //width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      "Sign up with us",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Create an account",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: <Widget>[
                    TextFormField(
                      onChanged: (value) {
                        name = value;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.supervised_user_circle),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(70),
                        ],
                        onChanged: (value) {
                          e_mail = value;
                        },
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          var helper = DatabaseHelper.instance
                              .CheckDonor()
                              .then((value) {
                            setState(() {
                              allDonorswithEmail = value;
                              elements = allDonorswithEmail;

                              print(elements);
                            });
                            var s3 = elements;
                            var query = emailController.text;

                            print('query');

                            print(query);

                            if (query.isNotEmpty) {
                              s3.forEach((element) {
                                var donor = Donors.fromMap(element);
                                var Emails = donor.email.toString();
                                if (Emails.toLowerCase()
                                    .contains(query.toLowerCase())) {
                                  x = 'This email already used';
                                } else
                                  x = '';
                              });
                            }
                          });

                          var helper2 =
                              DatabaseHelper.instance.CheckCHO().then((value) {
                            setState(() {
                              allDonorswithEmail2 = value;
                              elements2 = allDonorswithEmail2;

                              print(elements);
                            });
                            var s3 = elements;
                            var query = emailController.text;

                            print('query');

                            print(query);

                            if (query.isNotEmpty) {
                              s3.forEach((element) {
                                var cho = CHOs.fromMap(element);
                                var Emails = cho.email.toString();
                                if (Emails.toLowerCase()
                                    .contains(query.toLowerCase())) {
                                  x = 'This email already used';
                                } else
                                  x = '';
                              });
                            }
                          });

                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          } else if (!RegExp(
                                      "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                  .hasMatch(value) ||
                              value == null)
                            return 'Enter a valid email address';
                          else if (x == 'This email already used') {
                            return 'This email already used';
                          }
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                        controller: passController,
                        onChanged: (value) {
                          pass = value;
                          onPasswordChanged(value);
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.security),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          } else if (!RegExp(
                                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$')
                                  .hasMatch(value) ||
                              value == null)
                            return 'Enter valid password';
                          else if (value != null) {
                            pass = passController.text;
                            encryptedPass =
                                EncryptionDecryption.encryptAES(pass);

                            encryptedPass = encryptedPass.base64;
                            // print('encryptedPass: ' + encryptedPass);

                            //in log in page decrypt
                            // var x = Encrypted.from64(encryptedPass);
                            // var decryptedPass =
                            //  EncryptionDecryption.decryptAES(x);
                            // print('deccryptedPass: ' + decryptedPass);

                          }

                          //return null;
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              color: _isPasswordEightCharacters
                                  ? Colors.green
                                  : Colors.transparent,
                              border: _isPasswordEightCharacters
                                  ? Border.all(color: Colors.transparent)
                                  : Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(50)),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text("Contains at least 8 characters.")
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              color: _hasPasswordOneNumber
                                  ? Colors.green
                                  : Colors.transparent,
                              border: _hasPasswordOneNumber
                                  ? Border.all(color: Colors.transparent)
                                  : Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(50)),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text("Contains at least one number.")
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              color: _hasCapitalCharacter
                                  ? Colors.green
                                  : Colors.transparent,
                              border: _hasCapitalCharacter
                                  ? Border.all(color: Colors.transparent)
                                  : Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(50)),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text("Contains at least one capital letter.")
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              color: _hasLowerCaseCharacter
                                  ? Colors.green
                                  : Colors.transparent,
                              border: _hasLowerCaseCharacter
                                  ? Border.all(color: Colors.transparent)
                                  : Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(50)),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text("Contains at least one lower case letter.")
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              color: _hasSpecialCharacter
                                  ? Colors.green
                                  : Colors.transparent,
                              border: _hasSpecialCharacter
                                  ? Border.all(color: Colors.transparent)
                                  : Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(50)),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text("Contains at least one special character.")
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          var phoneint = int.parse(value);
                          phone = phoneint;
                        },
                        controller: phoneController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          var str = value.toString();

                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          } else if (!RegExp(r'^(?:[+0]9)?[0-9]{10}$')
                                  .hasMatch(value) ||
                              value == null ||
                              !str.startsWith('05'))
                            return 'Enter a valid phone number';
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5),
                      ],
                      onChanged: (value) {
                        var lNumint = int.parse(value);
                        _LicenseNo = lNumint;
                      },
                      controller: lNumberController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        labelText: 'License number',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        } else if (!LNum.contains(_LicenseNo))
                          return 'Please enter valid License number';
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                      children: [
                        Container(
                          child: DropdownSearch<String>(
                              mode: Mode.DIALOG,
                              showSelectedItems: true,
                              showSearchBox: true,
                              items: [
                                "Al ِAqiq",
                                "Al Amajiyah",
                                "Al Andalus ",
                                "Al Arid",
                                "Al Awali",
                                "Al Aziziah",
                                "Al Badiah",
                                "Al Batha",
                                "Al Birriyyah",
                                "Al Dar Albaida ",
                                "Al Dhubbat ",
                                " Al Difa",
                                "Al Dirah ",
                                "Al Dubiyah",
                                "Al Duraihimiyah ",
                                "Al Eamal",
                                "Al Faisalyah",
                                "Al Fakhiriyah",
                                "Al Falah",
                                "Al Faruq ",
                                "Al Fayha",
                                "Al Futah",
                                "Al Gadeer",
                                "Al Ghnamiah",
                                "Al Hada",
                                "Al Haeer",
                                "Al Hamra",
                                "Al Hazm",
                                "Al Iskan",
                                "Al Izdihar",
                                "Al Janadriyyah",
                                "Al Jaradiyah",
                                "Al Jazirah",
                                "Al Khaleej",
                                "Al Khalidiyyah",
                                "Al Khozama",
                                "Al Maazer",
                                "Al Mahdiyah",
                                "Al Maizilah",
                                "Al Malaz",
                                "Al Malqa",
                                "Al Manakh",
                                "Al Manar",
                                "Al Mansourah",
                                "Al Mansouriyah",
                                "Al Marqab",
                                "Al Marwah",
                                "Al Masani",
                                "Al Mashael",
                                "Al Masiaf",
                                "Al Misfat",
                                "Al Moatamarat",
                                "Al Mohammadiyyah",
                                "Al Mughrizat",
                                "Al Munsiyah",
                                "Al Murabba",
                                "Al Mursalat",
                                "Al Muruj",
                                "Al Nada",
                                "Al Nadheem",
                                "Al Nadwah",
                                "Al Nafal",
                                "Al Nahdah",
                                "Al Nakheel",
                                "Al Namudhajiya",
                                "Al Narjis",
                                "Al Nasiriyah",
                                "Al Nasim AlGharbi",
                                "Al Nasim Alshrqi",
                                "Al Noor",
                                "Al Nozha",
                                "Al Olaya",
                                "Al Oud",
                                "Al Qadisiyah",
                                "Al Qari",
                                "Al Qirawan",
                                "Al Quds",
                                "Al Rabie",
                                "Al Rabwah",
                                "Al Raed",
                                "Al Rafiah",
                                "Al Rahmaniyah",
                                "Al Rawabi",
                                "Al Rawdah",
                                "Al Rayan",
                                "Al Rimal",
                                "Al Saadah ",
                                "Al Safa",
                                "Al Safarat",
                                "Al Sahafa",
                                "Al Salam",
                                "Al Sharafiyah",
                                "Al Shemaysi",
                                "Al Shifa ",
                                "Al Sinaiyah",
                                "Al Sulay",
                                "Al Sulimaniyah",
                                "Al Suwaidi",
                                "Al Suwaidi Al Suwaidi",
                                "Al Taawun",
                                "Al Uraija",
                                " Al Uraija Alwusta ",
                                "Al Uraija Alchrbiyah",
                                "Al Wadi",
                                "Al Wisham",
                                "Al Wizarat",
                                "Al Wurud",
                                "Al Wusaita",
                                "Al Yamamah",
                                "Al Yarmouk",
                                "Al Yasmin",
                                "Al Zahra ",
                                "Al Zahrah ",
                                "Badr",
                                "Banban",
                                "Dhahrat Albadiah",
                                "Dhahrat Laban",
                                "Dirab",
                                "Ghirnatah",
                                "Ghubairah",
                                "Hijratlaban",
                                "Hittin",
                                "Hyt",
                                "Irqah",
                                "Ishbiliyah District ",
                                "Jabrah",
                                "Jarir",
                                "Khashm Alaan ",
                                "King AbdulAziz",
                                "King Abdullah",
                                "King Fahd",
                                "King Faisal",
                                "Manfuhah",
                                "Manfuhah Aljadidah ",
                                "Mikal",
                                "Namar",
                                "New Industrial Area",
                                "Qurtubah ",
                                "Salahuddin",
                                "Shubra",
                                "Siyah",
                                "Sultanah",
                                "Taybah",
                                "Thulaim",
                                "Uhud",
                                "Ulaishah",
                                "Umm Alhamam Algharbi",
                                "Umm Alhamam Alshrqi",
                                "Umm Salim",
                                "Uqadh ",
                                "Uraidh",
                                "Utaiqah",
                              ],
                              label: "Location",
                              hint: "what is your district",
                              selectedItem: location),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: ElevatedButton(
                          onPressed: () async {
                            //print(e_mail);
                            //print(pass);
                            try {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (formKey.currentState!.validate()) {
                                addCHO();
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data')),
                                );
                              }

                              /*   CHOs cho = CHOs(
                                email: emailController.text,
                                password: encryptedPass,
                                name: name,
                                location: location,
                                phone: phone,
                                lNumber: _LicenseNo,
                              );

                              await DatabaseHelper.instance.addCHOs(cho);*/

                              //print(await DatabaseHelper.instance.getCHOs());
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: const Text('Sign Up')),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Already have an account?"),
                    GestureDetector(
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// we will be creating a widget for text field
Widget inputFile({label, obscureText = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      const SizedBox(
        height: 5,
      ),
      TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
      ),
      const SizedBox(
        height: 10,
      )
    ],
  );
}
