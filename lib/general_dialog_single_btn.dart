import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralDialogSingleBtn extends StatelessWidget {
  final Function onBtnClick;
  final String title;
  final String btnText;

  const GeneralDialogSingleBtn({
    Key? key,
    required this.title,
    required this.onBtnClick,
    required this.btnText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 3),
                        spreadRadius: 0.5,
                        color: Colors.black26)
                  ],
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green.withOpacity(0.8)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8,left: 10,right: 10),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // const Padding(
                  //   padding: EdgeInsets.only(top: 16.0),
                  //   child: CustomDivider(),
                  // ),
                  SizedBox(
                    width: double.infinity,
                    child: Positioned(
                      //top: 12,
                      left: 40,
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                          onBtnClick();
                        },
                        child: Text(
                          btnText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
