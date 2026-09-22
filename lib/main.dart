import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _display = '0';
  bool _hasResult = false;

  bool _isOperator(String value) => '+-*/'.contains(value);

  void _press(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _display = '0';
        _hasResult = false;
        return;
      }

      if (value == '=') {
        _calculate();
        return;
      }

      if (_display.startsWith('Error')) {
        _expression = '';
        _display = '0';
      }

      if (_hasResult && _isOperator(value)) {
        _expression = _display.split(' = ').last + value;
      } else if (_hasResult) {
        _expression = value;
      } else if (_isOperator(value) &&
          (_expression.isEmpty ||
              _isOperator(_expression[_expression.length - 1]))) {
        if (_expression.isNotEmpty) {
          _expression =
              _expression.substring(0, _expression.length - 1) + value;
        }
      } else {
        _expression += value;
      }

      _display = _expression.isEmpty ? '0' : _expression;
      _hasResult = false;
    });
  }

  void _calculate() {
    if (_expression.isEmpty || _isOperator(_expression[_expression.length - 1])) {
      _display = 'Error: incomplete expression';
      _hasResult = true;
      return;
    }

    try {
      final expression = Expression.parse(_expression);
      final value = const ExpressionEvaluator().eval(expression, {});
      if (value is! num || value.isNaN || value.isInfinite) {
        throw const FormatException('invalid result');
      }
      final result = value == value.toInt()
          ? value.toInt().toString()
          : value.toString();
      _display = '$_expression = $result';
      _hasResult = true;
    } catch (_) {
      _display = 'Error: invalid expression';
      _hasResult = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    const buttons = [
      ['7', '8', '9', '/'],
      ['4', '5', '6', '*'],
      ['1', '2', '3', '-'],
      ['C', '0', '=', '+'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _display,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final row in buttons) ...[
                    Expanded(
                      child: Row(
                        children: [
                          for (final button in row)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: _CalculatorButton(
                                  label: button,
                                  onPressed: () => _press(button),
                                  isOperator:
                                      _isOperator(button) || button == '=',
                                  isClear: button == 'C',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.label,
    required this.onPressed,
    required this.isOperator,
    required this.isClear,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isOperator;
  final bool isClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isClear
            ? colorScheme.error
            : isOperator
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
        foregroundColor: isClear || isOperator
            ? colorScheme.onPrimary
            : colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 24)),
    );
  }
}
