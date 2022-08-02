import 'package:flutter/material.dart';
import 'package:gaslevel/constants.dart';
import 'package:gaslevel/pages/help_page.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  void _launchWebsiteURL() async {
    var url = Uri.parse("https://www.gaslock.de/");
    bool canLaunch = await launchUrl(url);
    if (canLaunch) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchInstagramURL() async {
    var url = Uri.parse(
        "https://www.instagram.com/accounts/login/?next=/gaslock_gmbh/");
    bool canLaunch = await launchUrl(url);
    if (canLaunch) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchFacebookURL() async {
    var url = Uri.parse("https://www.facebook.com/GaslockGmbH");
    bool canLaunch = await launchUrl(url);
    if (canLaunch) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchYoutubeURL() async {
    var url = Uri.parse("https://www.youtube.com/user/GASLEVELbyGASLOCK");
    bool canLaunch = await launchUrl(url);
    if (canLaunch) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Drawer(
      child: Container(
        color: const Color(0xFFF6F8F7),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('www.gaslock.de'),
              accountEmail: Text('info@gaslock.de'),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.asset(
                    'assets/new-logo.png',
                    width: 90,
                    height: 90,
                    //fit: BoxFit.cover,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(63),
                    bottomRight: Radius.circular(63)),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 5),
                    blurRadius: 60,
                    color: Colors.black54.withOpacity(0.29),
                  )
                ],
                image: DecorationImage(
                    image: AssetImage('assets/BKG1.jpg'), fit: BoxFit.cover),
              ),
            ),
            Column(
              children: [
                ListTile(
                    leading: Icon(Icons.arrow_back_outlined),
                    //title: Text('Follow us in Social Media'),
                    onTap: () => Navigator.pop(context)),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: size.width / 2,
                          height: 84,
                          child: Text("Folgen Sie uns in den sozialen Medien",
                          textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.2,
                              color: Colors.black54,
                              backgroundColor: Colors.green.withOpacity(0.06),
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      padding: EdgeInsets.all(kDefaultPadding / 2),
                      height: 62,
                      width: 62,
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 22,
                            color: kPrimaryColor.withOpacity(0.22),
                          ),
                          BoxShadow(
                            offset: Offset(-15, -15),
                            blurRadius: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: _launchInstagramURL,
                        child: Image.asset(
                          'assets/instagram.png',
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      padding: EdgeInsets.all(kDefaultPadding / 2),
                      height: 62,
                      width: 62,
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 22,
                            color: kPrimaryColor.withOpacity(0.22),
                          ),
                          BoxShadow(
                            offset: Offset(-15, -15),
                            blurRadius: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: _launchFacebookURL,
                        child: Image.asset(
                          'assets/facebook.png',
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      padding: EdgeInsets.all(kDefaultPadding / 2),
                      height: 62,
                      width: 62,
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 22,
                            color: kPrimaryColor.withOpacity(0.22),
                          ),
                          BoxShadow(
                            offset: Offset(-15, -15),
                            blurRadius: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: _launchWebsiteURL,
                        child: Image.asset(
                          'assets/website.png',
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      padding: EdgeInsets.all(kDefaultPadding / 2),
                      height: 62,
                      width: 62,
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 22,
                            color: kPrimaryColor.withOpacity(0.22),
                          ),
                          BoxShadow(
                            offset: Offset(-15, -15),
                            blurRadius: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: _launchYoutubeURL,
                        child: Image.asset(
                          'assets/youtube.png',
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // DrawerHeader(
            //   decoration: const BoxDecoration(
            //     color: Color(0xFFE4E7E5),
            //   ),
            //   child: Row(
            //     children: [
            //       const Spacer(),
            //       Expanded(
            //         flex: 4,
            //         child: Image.asset(
            //           'assets/Gaslevel-logoborder.png',
            //         ),
            //       ),
            //       const Spacer(),
            //     ],
            //   ),
            // ),
            // const SizedBox(
            //   height: 30,
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(builder: (context) => const HelpPage()),
            //     );
            //   },
            //   child: Row(
            //     children: [
            //       const Spacer(),
            //       Image.asset(
            //         'assets/help.png',
            //       ),
            //       const SizedBox(
            //         width: 20,
            //       ),
            //       const Text(
            //         'Anleitung',
            //         style: TextStyle(fontSize: 20),
            //       ),
            //       const Spacer(
            //         flex: 5,
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(
            //   height: 30,
            // ),
          ],
        ),
      ),
    );
  }
}
