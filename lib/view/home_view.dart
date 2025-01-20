import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_galaxy/widgets/custom_button_widget.dart';
import 'package:liquid_galaxy/controller/ssh_controller.dart';

class HomeView extends StatelessWidget {
  final SSHController _controller = Get.put(SSHController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8BFD8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Obx(
          () => Icon(
            Icons.circle,
            color: _controller.isConnected.value ? Colors.green : Colors.red,
          ),
        ),
        title: const Text(
          'Task 2',
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.grey),
              onPressed: () => Get.toNamed('/settings'),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ..._buildDynamicButtons(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicButtons() {
    final List<Map<String, dynamic>> buttonConfig = [
      {
        'buttons': [
          {'text': 'SEND LOGO', 'action': _controller.sendLogo},
        ],
      },
      {
        'buttons': [
          {'text': 'SEND KML1', 'action': _controller.sendKml1},
          {'text': 'SEND KML2', 'action': _controller.sendKml2},
        ],
      },
      {
        'buttons': [
          {'text': 'CLEAN KMLs', 'action': _controller.cleanKml},
          {'text': 'CLEAN LOGO', 'action': _controller.cleanLogo},
        ],
      },
    ];

    return buttonConfig.expand((config) {
      if (config['isSingle'] == true) {
        return [
          SizedBox(
            width: double.infinity,
            child: CustomButtonWidget(
              text: config['buttons'][0]['text'],
              onPressed: config['buttons'][0]['action'],
            ),
          ),
          const SizedBox(height: 20),
        ];
      } else {
        return [
          _buildButtonRow(config['buttons']),
          const SizedBox(height: 20),
        ];
      }
    }).toList();
  }

  Widget _buildButtonRow(List<Map<String, dynamic>> buttons) {
    return Row(
      children: buttons.map((button) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: CustomButtonWidget(
              text: button['text'],
              onPressed: button['action'],
            ),
          ),
        );
      }).toList(),
    );
  }
}
