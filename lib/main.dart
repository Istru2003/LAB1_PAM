import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MaterialApp(
    title: 'Currency Converter',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    debugShowCheckedModeBanner: false,
    home: CurrencyConverterScreen(),
  ));
}

// Ecranul principal pentru convertorul de valute
class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String _fromCurrency = 'MDL'; // Moneda din care se face conversia
  String _toCurrency = 'USD'; // Moneda în care se face conversia
  TextEditingController _fromController = TextEditingController(); // Controller pentru suma introdusă
  TextEditingController _toController = TextEditingController(); // Controller pentru suma convertită
  TextEditingController _exchangeRateController = TextEditingController(); // Controller pentru rata de schimb
  double _exchangeRate = 1.0; // Rata de schimb curentă

  final List<String> _currencies = [
    // Lista monedelor disponibile pentru conversie
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'HKD', 'NZD',
    'SEK', 'KRW', 'SGD', 'NOK', 'MXN', 'INR', 'RUB', 'ZAR', 'TRY', 'BRL',
    'TWD', 'DKK', 'PLN', 'THB', 'IDR', 'HUF', 'CZK', 'ILS', 'CLP', 'PHP',
    'AED', 'COP', 'SAR', 'MYR', 'RON', 'MDL'
  ];

  // Asocierea dintre monedă și drapelul corespunzător
  final Map<String, String> _flagImages = {
    'USD': 'assets/flags/us.png',
    'EUR': 'assets/flags/eu.png',
    'GBP': 'assets/flags/gb.png',
    'JPY': 'assets/flags/jp.png',
    'AUD': 'assets/flags/au.png',
    'CAD': 'assets/flags/ca.png',
    'CHF': 'assets/flags/ch.png',
    'CNY': 'assets/flags/cn.png',
    'HKD': 'assets/flags/hk.png',
    'NZD': 'assets/flags/nz.png',
    'SEK': 'assets/flags/se.png',
    'KRW': 'assets/flags/kr.png',
    'SGD': 'assets/flags/sg.png',
    'NOK': 'assets/flags/no.png',
    'MXN': 'assets/flags/mx.png',
    'INR': 'assets/flags/in.png',
    'RUB': 'assets/flags/ru.png',
    'ZAR': 'assets/flags/za.png',
    'TRY': 'assets/flags/tr.png',
    'BRL': 'assets/flags/br.png',
    'TWD': 'assets/flags/tw.png',
    'DKK': 'assets/flags/dk.png',
    'PLN': 'assets/flags/pl.png',
    'THB': 'assets/flags/th.png',
    'IDR': 'assets/flags/id.png',
    'HUF': 'assets/flags/hu.png',
    'CZK': 'assets/flags/cz.png',
    'ILS': 'assets/flags/il.png',
    'CLP': 'assets/flags/cl.png',
    'PHP': 'assets/flags/ph.png',
    'AED': 'assets/flags/ae.png',
    'COP': 'assets/flags/co.png',
    'SAR': 'assets/flags/sa.png',
    'MYR': 'assets/flags/my.png',
    'RON': 'assets/flags/ro.png',
    'MDL': 'assets/flags/md.png',
  };

  @override
  void initState() {
    super.initState();
    _fromController.text = ""; // Inițializare câmp pentru suma introdusă
    _exchangeRateController.text = ""; // Inițializare câmp pentru rata de schimb
    _convertCurrency(); // Convertirea automată la pornire
  }

  // Funcția pentru a schimba monedele
  void _swapCurrencies() {
    setState(() {
      String tempCurrency = _fromCurrency; // Salvarea temporară a monedei din care se face conversia
      _fromCurrency = _toCurrency; // Schimbarea monedei din care se face conversia cu cea în care se face conversia
      _toCurrency = tempCurrency; // Schimbarea inversă

      String tempAmmount = _fromController.text; // Schimbarea sumelor introduse
      _fromController.text = _toController.text;
      _toController.text = tempAmmount;

      if (_exchangeRateController.text.isNotEmpty) {
        _exchangeRate = 1 / _exchangeRate; // Inversarea ratei de schimb
        _exchangeRateController.text = _exchangeRate.toStringAsFixed(6); // Actualizarea valorii ratei de schimb
      }
      _convertCurrency(); // Reconvertirea sumelor
    });
  }

  @override
  void dispose() {
    _fromController.dispose(); // Eliberarea resurselor pentru controller
    _toController.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  // Funcția pentru a converti sumele
  void _convertCurrency() {
    if (_fromController.text.isNotEmpty && _exchangeRateController.text.isNotEmpty) {
      double fromAmount = double.tryParse(_fromController.text) ?? 0; // Parcurgerea sumei introduse
      double toAmount = fromAmount / _exchangeRate; // Calcularea sumei convertite
      _toController.text = toAmount.toStringAsFixed(2); // Afișarea sumei convertite
    } else {
      _toController.text = ''; // Dacă nu există date, golim câmpul
    }
  }

  // Widget pentru afișarea cardului de conversie
  Widget _buildConverterCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          _buildCurrencyInput('Amount', _fromCurrency, _fromController), // Câmp pentru suma introdusă
          Stack(
            alignment: Alignment.center,
            children: [
              Divider(height: 1, thickness: 1, color: Colors.grey[200]),
              _buildSwapButton(), // Buton pentru a schimba monedele
            ],
          ),
          _buildCurrencyInput('Converted Amount', _toCurrency, _toController, readOnly: true), // Câmp pentru suma convertită
        ],
      ),
    );
  }

  // Buton pentru a schimba monedele
  Widget _buildSwapButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF4A3AFF),
      ),
      child: IconButton(
        icon: Icon(Icons.swap_vert, color: Colors.white),
        onPressed: _swapCurrencies,
        padding: EdgeInsets.zero,
      ),
    );
  }

  // Informații despre rata de schimb
  Widget _buildExchangeRateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indicative Exchange Rate', // Text despre rata de schimb
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              '1 $_toCurrency = ', // Afișarea unei părți a ratei de schimb
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _exchangeRateController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        _exchangeRate = double.tryParse(_exchangeRateController.text) ?? 1.0; // Actualizarea ratei de schimb
                        _convertCurrency(); // Reconvertirea sumei
                      },
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    _fromCurrency, // Afișarea monedei de bază
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget pentru câmpurile de introducere a sumei
  Widget _buildCurrencyInput(String label, String currency, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)), // Eticheta câmpului
          SizedBox(height: 8),
          Row(
            children: [
              _buildCurrencyDropdown(currency, (value) {
                setState(() {
                  if (currency == _fromCurrency) {
                    _fromCurrency = value!; // Schimbarea monedei din care se face conversia
                  } else {
                    _toCurrency = value!; // Schimbarea monedei în care se face conversia
                  }
                  _convertCurrency(); // Reconvertirea sumei
                });
              }),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                  ),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  readOnly: readOnly, // Control asupra editabilității câmpului
                  onChanged: readOnly ? null : (_) => _convertCurrency(), // Reconvertirea sumei când se schimbă valoarea
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pentru meniul derulant de selectare a monedei
  Widget _buildCurrencyDropdown(String value, void Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        items: _currencies.map((String currency) {
          return DropdownMenuItem<String>(
            value: currency,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(_flagImages[currency]!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(currency, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Setarea fundalului
      appBar: AppBar(
        backgroundColor: Colors.grey[100], // Setarea fundalului pentru AppBar
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Stilul interfeței sistemului
        title: Text(
          'Currency Converter', // Titlul aplicației
          style: TextStyle(color: Color(0xFF2A2A2A), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConverterCard(), // Afișarea cardului de conversie
              SizedBox(height: 24),
              _buildExchangeRateInfo(), // Afișarea informațiilor despre rata de schimb
            ],
          ),
        ),
      ),
    );
  }
}
