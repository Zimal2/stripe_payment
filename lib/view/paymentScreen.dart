import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_payment/constants/reuseableTextFeild.dart';
import 'package:stripe_payment/controller/paymentMethod.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();

  final formkey = GlobalKey<FormState>();
  final formkey1 = GlobalKey<FormState>();
  final formkey2 = GlobalKey<FormState>();
  final formkey3 = GlobalKey<FormState>();
  final formkey4 = GlobalKey<FormState>();
  final formkey5 = GlobalKey<FormState>();
  final formkey6 = GlobalKey<FormState>();

  List<String> currencyList = <String>[
    'USD',
    'INR',
    'EUR',
    'JPY',
    'GBP',
    'AED'
  ];
  String selectedCurrency = 'USD';

  Future<void> initPaymentSheet() async {
    try {
      // 1. create payment intent on the client side by calling stripe api
      final data = await createPaymentIntent(
          // convert string to double
          amount: (int.parse(amountController.text) * 100).toString(),
          currency: selectedCurrency,
          name: nameController.text,
          address: addressController.text,
          pin: pincodeController.text,
          city: cityController.text,
          state: stateController.text,
          country: countryController.text);

      // 2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Set to true for custom flow
          customFlow: false,
          // Main params
          merchantDisplayName: 'Test Merchant',
          paymentIntentClientSecret: data['client_secret'],
          // Customer keys
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],

          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300,
                width: 500,
                child: Image.network(
                    fit: BoxFit.cover,
                    'https://i.pinimg.com/564x/d5/ef/94/d5ef94dc790bd17ff299e26dbfe310f4.jpg'),
              ),
              SizedBox(
                height: 15,
              ),
              const Text(
                "Enter your details:",
                style: TextStyle(fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ReusableTextField(
                              formkey: formkey,
                              controller: amountController,
                              isNumber: true,
                              title: "Sending Amount",
                              hint: "Any amount you like"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        DropdownMenu<String>(
                          inputDecorationTheme: InputDecorationTheme(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 0),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          initialSelection: currencyList.first,
                          onSelected: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              selectedCurrency = value!;
                            });
                          },
                          dropdownMenuEntries: currencyList
                              .map<DropdownMenuEntry<String>>((String value) {
                            return DropdownMenuEntry<String>(
                                value: value, label: value);
                          }).toList(),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ReusableTextField(
                      formkey: formkey1,
                      title: "Name",
                      hint: "Ex. John Doe",
                      controller: nameController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ReusableTextField(
                      formkey: formkey2,
                      title: "Address Line",
                      hint: "Ex. 123 Main St",
                      controller: addressController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 5,
                            child: ReusableTextField(
                              formkey: formkey3,
                              title: "City",
                              hint: "Ex. Lahore",
                              controller: cityController,
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            flex: 5,
                            child: ReusableTextField(
                              formkey: formkey4,
                              title: "State (Short code)",
                              hint: "Ex. ISB for islamabad",
                              controller: stateController,
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 5,
                            child: ReusableTextField(
                              formkey: formkey5,
                              title: "Country (Short Code)",
                              hint: "Ex. PK for Pakistan",
                              controller: countryController,
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            flex: 5,
                            child: ReusableTextField(
                              formkey: formkey6,
                              title: "Pincode",
                              hint: "Ex. 123456",
                              controller: pincodeController,
                              isNumber: true,
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (formkey.currentState!.validate() &&
                            formkey1.currentState!.validate() &&
                            formkey2.currentState!.validate() &&
                            formkey3.currentState!.validate() &&
                            formkey4.currentState!.validate() &&
                            formkey5.currentState!.validate() &&
                            formkey6.currentState!.validate()) {
                          await initPaymentSheet();

                          try {
                            await Stripe.instance.presentPaymentSheet();

                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                "Payment Done",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ));

                            nameController.clear();
                            addressController.clear();
                            cityController.clear();
                            stateController.clear();
                            countryController.clear();
                            pincodeController.clear();
                          } catch (e) {
                            print("payment sheet failed");
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                "Payment Failed",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                            ));
                          }
                        }
                      },
                      child: const Text("Proceed",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Background color
                        fixedSize:
                            const Size(200, 40), // Width 200 and height 50
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
