import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SSHController extends GetxController {
  late RxString ipAddress = ''.obs;
  late RxString sshPort = ''.obs;
  late RxString userName = ''.obs;
  late RxString password = ''.obs;
  late RxString numberOfRigs = ''.obs;
  RxBool isConnected = false.obs;
  RxBool isLoading = true.obs;
  RxBool isChanged = false.obs;
  SSHClient? client;

  @override
  void onInit() {
    super.onInit();
    connectToLG();
    fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      ipAddress.value = prefs.getString('ipAddress') ?? '';
      sshPort.value = prefs.getString('sshPort') ?? '';
      userName.value = prefs.getString('userName') ?? '';
      password.value = prefs.getString('password') ?? '';
      numberOfRigs.value = prefs.getString('numberOfRigs') ?? '';
      
      ipAddress.listen((_) => isChanged.value = true);
      sshPort.listen((_) => isChanged.value = true);
      userName.listen((_) => isChanged.value = true);
      password.listen((_) => isChanged.value = true);
      numberOfRigs.listen((_) => isChanged.value = true);

      final connectionData = {
        'ipAddress': ipAddress.value,
        'sshPort': sshPort.value,
        'userName': userName.value,
        'password': password.value,
        'numberOfRigs': numberOfRigs.value,
      };

      return connectionData;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('ipAddress', ipAddress.value);
      await prefs.setString('sshPort', sshPort.value);
      await prefs.setString('userName', userName.value);
      await prefs.setString('password', password.value);
      await prefs.setString('numberOfRigs', numberOfRigs.value);

    } catch (error) {
      // print('Error updating data: $error');
      isConnected.value = false;
    }
  }

  void updateConnectionStatus(bool status) {
    isConnected.value = status;
    update();
  }

  // Connect LG with retries
  Future<bool?> connectToLG({int maxRetries = 10}) async {
    int retryCount = 0;

    while (retryCount < maxRetries && !isConnected.value) {
      await fetchData();

      try {
        int port;
        if (sshPort.value != '') {
          port = int.parse(sshPort.value);
        } else {
          // print('SSH Port value is null');
          return false;
        }

        client = SSHClient(
          await SSHSocket.connect(ipAddress.value, port),
          username: userName.value,
          onPasswordRequest: () => password.value,
          keepAliveInterval: const Duration(seconds: 36000000),
          onAuthenticated: () => isConnected.value = true,
        );

        Get.snackbar(
          'Successful',
          'Connected to LG Rigs',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        return true;
      } on SocketException catch (e) {
        print(e);
        isConnected.value = false;
        retryCount++;

        if (retryCount == 1) {
          Get.snackbar(
            'Failed',
            'Retrying connection (attempt $retryCount)...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }

        await Future.delayed(const Duration(seconds: 1));

        continue;
      } catch (e) {
        // print('Exception occurred: $e');
        isConnected.value = false;
        return false;
      }
    }

    if (!isConnected.value) {
      Get.snackbar(
        'Connection Error',
        'Failed to connect after $maxRetries attempts.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // print('Failed to connect after $maxRetries attempts.');
      return false;
    }

    return true;
  }

  int get leftSlave {
    if (int.parse(numberOfRigs.value) == 1) {
      return 1;
    }

    return (int.parse(numberOfRigs.value) / 2).floor() + 2;
  }

  int get rightSlave {
    if (int.parse(numberOfRigs.value) == 1) {
      return 1;
    }

    return (int.parse(numberOfRigs.value) / 2).floor() + 1;
  }

//clean kml
  Future<void> cleanKml() async {
  try {
    if (ipAddress.value.isEmpty || isConnected.value == false) {
      return;
    }
    
    String fileName = 'cleaned_kml.kml';
    await client!.execute("echo 'http://lg1:81/$fileName' > /var/www/html/kmls.txt");
  } catch (e) {
    return;
  }
}

//clean logo
Future<void> cleanLogo() async {
  String kmlName = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2"
xmlns:gx="http://www.google.com/kml/ext/2.2"
xmlns:kml="http://www.opengis.net/kml/2.2"
xmlns:atom="http://www.w3.org/2005/Atom">
  <Document id="3">
  </Document>
</kml>
''';

  try {
    if (ipAddress.value.isEmpty || isConnected.value == false) {
      return;
    }
    await client!.execute("echo '$kmlName' > /var/www/html/kml/slave_$leftSlave.kml");
  } catch (e) {
    return;
  }
}

//send kml
 Future<void> sendKml1() async {
  String kmlName = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Altamount Road, Mumbai</name>
    <description>
      Altamount Road, located in South Mumbai, is known as India's "Billionaires' Row," home to some of the wealthiest individuals in the country.
    </description>

    <Placemark>
      <name>Antilia</name>
      <description>Mukesh Ambani's residence, one of the most expensive homes in the world.</description>
      <Point>
        <coordinates>72.8087,18.9682</coordinates>
      </Point>
      <Style>
        <IconStyle>
          <Icon>
            <href>http://maps.google.com/mapfiles/kml/shapes/homegardenbusiness.png</href>
          </Icon>
          <scale>1.2</scale>
          <color>ff0000ff</color>
        </IconStyle>
      </Style>
    </Placemark>

    <Placemark>
      <name>Altamount Road Zone</name>
      <description>Richest neighborhood in India, featuring luxurious residential buildings.</description>
      <Polygon>
        <outerBoundaryIs>
          <LinearRing>
            <coordinates>
              72.8080,18.9691,0
              72.8102,18.9691,0
              72.8102,18.9670,0
              72.8080,18.9670,0
              72.8080,18.9691,0
            </coordinates>
          </LinearRing>
        </outerBoundaryIs>
      </Polygon>
      <Style>
        <PolyStyle>
          <color>7dffcc00</color>
          <outline>1</outline>
        </PolyStyle>
      </Style>
    </Placemark>

  </Document>
</kml>
''';

  kmlName = kmlName.replaceAll('"', r'\"').replaceAll("\n", "");
  
  try {
    if (ipAddress.value.isEmpty || isConnected.value == false) {
      return;
    }

    String fileName = 'antilia.kml';
    String ecoCommand = 'echo "$kmlName" > /var/www/html/$fileName';
    await client!.execute(ecoCommand);
    await client!.execute("echo 'http://lg1:81/$fileName' > /var/www/html/kmls.txt");
    double latitude = 18.9683;
    double longitude = 72.8090;
    double range = 2620;
    
   String orbitLookAtLinear =
        '<gx:duration>3</gx:duration><gx:flyToMode>smooth</gx:flyToMode>'
        '<LookAt>'
        '<longitude>$longitude</longitude>'
        '<latitude>$latitude</latitude>'
        '<range>$range</range>'
        '<tilt>60</tilt>'
        '<heading>10.0</heading>'
        '<gx:altitudeMode>relativeToGround</gx:altitudeMode>'
        '</LookAt>';

    await client!.execute('echo "flytoview=$orbitLookAtLinear" > /tmp/query.txt');
  } catch (e) {
    // print("Error: $e");
  }
}

//send kml 2
 Future<void> sendKml2() async {
  String kmlName = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Kumbh Mela Prayagraj</name>
    <description>Explore the Kumbh Mela locations in Prayagraj</description>

    <Placemark>
      <name>Triveni Sangam</name>
      <description>
        Sacred confluence of Ganges, Yamuna, and Saraswati rivers.
        The site where millions gather for the holy dip during Kumbh Mela.
      </description>
      <Point>
        <coordinates>81.8852,25.4328</coordinates>
      </Point>
      <Style>
        <IconStyle>
          <Icon>
            <href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href>
          </Icon>
        </IconStyle>
      </Style>
    </Placemark>

    <Placemark>
      <name>Ganga Ghat</name>
      <description>
        Main bathing ghat on the banks of the Ganges.
        A sacred spot for rituals during Kumbh Mela.
      </description>
      <Point>
        <coordinates>81.8767,25.4301</coordinates>
      </Point>
      <Style>
        <IconStyle>
          <Icon>
            <href>https://www.google.com/maps/vt/icon/name=photo_marker</href>
          </Icon>
        </IconStyle>
      </Style>
    </Placemark>

    <Placemark>
      <name>Yamuna Ghat</name>
      <description>
        Bathing ghat along the Yamuna river.
        Another important spot for rituals.
      </description>
      <Point>
        <coordinates>81.8714,25.4333</coordinates>
      </Point>
      <Style>
        <IconStyle>
          <Icon>
            <href>https://www.google.com/maps/vt/icon/name=photo_marker</href>
          </Icon>
        </IconStyle>
      </Style>
    </Placemark>

    <Placemark>
      <name>Pilgrim Route</name>
      <description>The primary routes for pilgrims during Kumbh Mela.</description>
      <LineString>
        <coordinates>
          81.8852,25.4328,0
          81.8790,25.4315,0
          81.8740,25.4330,0
          81.8700,25.4345,0
        </coordinates>
      </LineString>
      <Style>
        <LineStyle>
          <color>ff00ff00</color>
          <width>5</width>
        </LineStyle>
      </Style>
    </Placemark>

    <Placemark>
      <name>Kumbh Mela Zone</name>
      <description>
        The area designated for Kumbh Mela activities.
        Includes all main events and areas for congregation.
      </description>
      <Polygon>
        <outerBoundaryIs>
          <LinearRing>
            <coordinates>
              81.8880,25.4325,0
              81.8865,25.4310,0
              81.8840,25.4335,0
              81.8852,25.4340,0
              81.8880,25.4325,0
            </coordinates>
          </LinearRing>
        </outerBoundaryIs>
      </Polygon>
      <Style>
        <PolyStyle>
          <color>7dff0000</color>
          <outline>1</outline>
        </PolyStyle>
      </Style>
    </Placemark>

    <Placemark>
      <name>Temporary Camp Zone</name>
      <description>
        Zone for temporary camps during the Kumbh Mela.
        This is where pilgrims set up temporary shelters.
      </description>
      <Polygon>
        <outerBoundaryIs>
          <LinearRing>
            <coordinates>
              81.8770,25.4300,0
              81.8800,25.4290,0
              81.8820,25.4310,0
              81.8795,25.4325,0
              81.8770,25.4300,0
            </coordinates>
          </LinearRing>
        </outerBoundaryIs>
      </Polygon>
      <Style>
        <PolyStyle>
          <color>7d00ff00</color>
        </PolyStyle>
      </Style>
    </Placemark>
  </Document>
</kml>
''';

  kmlName = kmlName.replaceAll('"', r'\"').replaceAll("\n", "");
  
  try {
    if (ipAddress.value.isEmpty || isConnected.value == false) {
      return;
    }

    String fileName = 'kumbh.kml';
    String ecoCommand = 'echo "$kmlName" > /var/www/html/$fileName';
    await client!.execute(ecoCommand);
    await client!.execute("echo 'http://lg1:81/$fileName' > /var/www/html/kmls.txt");
    double latitude = 25.4315;
    double longitude = 81.8785;
    double range = 2620;
    
   String orbitLookAtLinear =
        '<gx:duration>3</gx:duration><gx:flyToMode>smooth</gx:flyToMode>'
        '<LookAt>'
        '<longitude>$longitude</longitude>'
        '<latitude>$latitude</latitude>'
        '<range>$range</range>'
        '<tilt>60</tilt>'
        '<heading>10.0</heading>'
        '<gx:altitudeMode>relativeToGround</gx:altitudeMode>'
        '</LookAt>';

    await client!.execute('echo "flytoview=$orbitLookAtLinear" > /tmp/query.txt');
  } catch (e) {
    // print("Error: $e");
  }
}

//send logo
Future<SSHSession?> sendLogo() async {
    String kmlName = '''
<kml xmlns="http://www.opengis.net/kml/2.2"
     xmlns:atom="http://www.w3.org/2005/Atom"
     xmlns:gx="http://www.google.com/kml/ext/2.2">
    <Document>
        <Folder>
            <name>Logos</name>
            <ScreenOverlay>
                <name>Logo</name>
                <Icon>
                    <href>https://raw.githubusercontent.com/oiiakm/Liquid-Galaxy-Connection-/main/assets/logo.jpg</href>
                </Icon>
                <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                <screenXY x="0.0" y="1" xunits="fraction" yunits="fraction"/>
                <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                <size x="0" y="0" xunits="pixels" yunits="pixels"/>
            </ScreenOverlay>
        </Folder>
    </Document>
</kml>
''';
    try {
      if (ipAddress.value.isEmpty || isConnected.value == false) {
        return null;
      }

      SSHSession result = await client!
          .execute("echo '$kmlName' > /var/www/html/kml/slave_$leftSlave.kml");

      return result;
    } catch (e) {
      return null;
    }
  }

}
