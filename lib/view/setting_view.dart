import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_galaxy/controller/ssh_controller.dart';
import 'package:liquid_galaxy/widgets/custome_text_field_widget.dart';

class SettingView extends StatelessWidget {
  final SSHController _viewModel = Get.put(SSHController());

  SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text('Settings',style: TextStyle(color: Colors.black,fontFamily: 'Inter',fontWeight: FontWeight.w500),),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
          children: [
            Obx(() => 
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _viewModel.isConnected.value
                      ? [ Colors.green.shade400,Colors.green.shade100]
                      : [ Colors.red.shade400,Colors.red.shade100,],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            ),
            Obx(() {
              if (_viewModel.isConnected.value==false) {
                return const Positioned(
                top: 20,
                right: 27,
                child: BlinkingIndicator(
                  child: Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'Disconnected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
              } else {
                return const SizedBox();
              }
            }),
            FutureBuilder<Map<String, dynamic>>(
              future: _viewModel.fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 55.0),
                        CustomTextFieldWidget(
                          labelText: 'IP Address',
                          hintText: '255.255.255.255',
                          initialValue: _viewModel.ipAddress.value,
                          onChanged: (value) => _viewModel.ipAddress.value = value,
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextFieldWidget(
                          labelText: 'Port',
                          hintText: '22',
                          initialValue: _viewModel.sshPort.value,
                          onChanged: (value) => _viewModel.sshPort.value = value,
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextFieldWidget(
                          labelText: 'Username',
                          hintText: 'lg',
                          initialValue: _viewModel.userName.value,
                          onChanged: (value) => _viewModel.userName.value = value,
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextFieldWidget(
                          labelText: 'Password',
                          hintText: 'lg',
                          obsecureText: true,
                          initialValue: _viewModel.password.value,
                          onChanged: (value) => _viewModel.password.value = value,
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextFieldWidget(
                          labelText: 'Number Of Rigs',
                          hintText: '3',
                          initialValue: _viewModel.numberOfRigs.value,
                          onChanged: (value) => _viewModel.numberOfRigs.value = value,
                        ),
                        const SizedBox(height: 30.0),
                        Obx(
                          () => ElevatedButton(
                          onPressed: _viewModel.isChanged.value==false && _viewModel.isConnected.value==true ? null : () async {
                            _viewModel.updateConnectionStatus(false);
                            await _viewModel.updateData();
                            await _viewModel.connectToLG(maxRetries: 1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ), 
    );
  }
}

class BlinkingIndicator extends StatefulWidget {
  final Widget child;

  const BlinkingIndicator({super.key, required this.child});

  @override
  State<BlinkingIndicator> createState() => _BlinkingIndicatorState();
}

class _BlinkingIndicatorState extends State<BlinkingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: widget.child,
    );
  }
}
