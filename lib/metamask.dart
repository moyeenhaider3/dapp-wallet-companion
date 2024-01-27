import 'package:flutter/material.dart';
import 'package:wallet_app/utils/custom_chain.dart';
import 'package:wallet_app/widgets/dialog.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class MetaMaskSignUp extends StatefulWidget {
  const MetaMaskSignUp({super.key});

  @override
  State<MetaMaskSignUp> createState() => _MetaMaskSignUpState();
}

class _MetaMaskSignUpState extends State<MetaMaskSignUp> {
  late final W3MService _w3mService;
  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() async {
    // See https://docs.walletconnect.com/web3modal/flutter/custom-chains
    W3MChainPresets.chains.putIfAbsent('11155111', () => sepoliaTestnet);

    _w3mService = W3MService(
      projectId: '41fd213cf735e02b804dbd0b19c23f70',
      logLevel: LogLevel.error,
      metadata: const PairingMetadata(
        name: 'Web3Modal Flutter Example',
        description: 'Web3Modal Flutter Example',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'flutterdapp://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
      includedWalletIds: {
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // Metamask
      },
      featuredWalletIds: {
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
      },
    );
    await _w3mService.init();

    // If you want to support just one chain uncomment this line and avoid using W3MNetworkSelectButton()
    // _w3mService.selectChain(W3MChainPresets.chains['137']);

    _w3mService.addListener(_serviceListener);
    _w3mService.onSessionEventEvent.subscribe(_onSessionEvent);
    _w3mService.onSessionUpdateEvent.subscribe(_onSessionUpdate);
    _w3mService.onSessionConnectEvent.subscribe(_onSessionConnect);
    _w3mService.onSessionDeleteEvent.subscribe(_onSessionDelete);
  }

  void _onSessionEvent(SessionEvent? args) {
    debugPrint('[$runtimeType] _onSessionEvent $args');
  }

  void _onSessionUpdate(SessionUpdate? args) {
    debugPrint('[$runtimeType] _onSessionUpdate $args');
  }

  void _onSessionConnect(SessionConnect? args) {
    debugPrint('[$runtimeType] _onSessionConnect $args');
  }

  void _onSessionDelete(SessionDelete? args) {
    debugPrint('[$runtimeType] _onSessionDelete $args');
  }

  @override
  void dispose() {
    _w3mService.onSessionEventEvent.unsubscribe(_onSessionEvent);
    _w3mService.onSessionUpdateEvent.unsubscribe(_onSessionUpdate);
    _w3mService.onSessionConnectEvent.unsubscribe(_onSessionConnect);
    _w3mService.onSessionDeleteEvent.unsubscribe(_onSessionDelete);
    super.dispose();
  }

  void _serviceListener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Web3ModalTheme.colorsOf(context).background125,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('Web3Modal Flutter'),
        backgroundColor: Web3ModalTheme.colorsOf(context).background175,
        foregroundColor: Web3ModalTheme.colorsOf(context).foreground100,
      ),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ButtonsView(w3mService: _w3mService),
          const Divider(height: 0.0, color: Colors.transparent),
          _ConnectedView(w3mService: _w3mService)
        ],
      ),
    );
  }
}

class _ButtonsView extends StatelessWidget {
  const _ButtonsView({required this.w3mService});
  final W3MService w3mService;

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox.square(dimension: 8.0),
        Visibility(
          visible: !w3mService.isConnected,
          child: W3MNetworkSelectButton(service: w3mService),
        ),
        W3MConnectWalletButton(service: w3mService),
        const SizedBox.square(dimension: 8.0),
      ],
    );
  }
}

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({required this.w3mService});
  final W3MService w3mService;

  @override
  Widget build(BuildContext context) {
    if (!w3mService.isConnected) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox.square(dimension: 12.0),
        W3MAccountButton(service: w3mService),
        const SizedBox.square(dimension: 12.0),
        ElevatedButton(
          onPressed: () {
            _onSignMessageClicked(context);
          },
          child: const Text('Sign Message'),
        ),
        const SizedBox.square(dimension: 8.0),
        ElevatedButton(
          onPressed: () {
            // Handle the "Send Transaction" button click
          },
          child: const Text('Send Transaction'),
        ),
        const SizedBox.square(dimension: 12.0),
      ],
    );
  }

  Future<void> _onSignMessageClicked(BuildContext context) async {
    try {
      final response = await w3mService.web3App!.request(
        topic: w3mService.session!.topic!,
        chainId: '11155111',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [
            'moyeen is doing transaction',
            w3mService.session!.getAccounts()!.first
          ],
        ),
      );
      showSignMessageResultDialog(context, response.toString());
    } catch (error) {
      showSignMessageResultDialog(context, 'Error: $error');
    }
  }
}
