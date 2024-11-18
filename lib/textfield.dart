import 'package:flutter/material.dart';

class EigenTekstField extends StatelessWidget {
   EigenTekstField({super.key});

  String binnentekst;
  String buitentekst;

  EigenTekstField(String buitentekst, String binnentekst) {
    this.buitentekst = buitentekst;
    this.binnentekst = binnentekst;
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
