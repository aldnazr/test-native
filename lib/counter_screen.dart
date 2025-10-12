import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/provider/counter_provider.dart';

class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterProv = ref.watch(counterProvider);
    final counterProvNotif = ref.read(counterProvider.notifier);
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Counter')),
      body: Column(
        spacing: 14.0,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Text(
                  counterProv.toString(),
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ),
          ),
          Row(
            spacing: 8.0,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: counterProvNotif.increment,
                icon: Icon(Icons.add),
              ),
              IconButton.filledTonal(
                onPressed: counterProvNotif.decrement,
                icon: Icon(Icons.remove),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
