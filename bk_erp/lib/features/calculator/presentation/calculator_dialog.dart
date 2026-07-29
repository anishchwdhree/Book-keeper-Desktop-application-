import 'package:bk_erp/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({super.key});

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  final FocusNode _focusNode = FocusNode();
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldClearDisplay = false;
  double _memory = 0.0;
  String _historyDisplay = '';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (['+', '-', '×', '÷'].contains(key)) {
        if (_operator != null && !_shouldClearDisplay) {
          _calculate();
        }
        _firstOperand = double.tryParse(_display);
        _operator = key;
        _historyDisplay = '${_formatNumber(_firstOperand)} $key';
        _shouldClearDisplay = true;
      } else if (key == '=' || key == 'Enter') {
        if (_operator != null && _firstOperand != null) {
          final secondOperand = double.tryParse(_display) ?? 0.0;
          _historyDisplay = '${_formatNumber(_firstOperand)} $_operator ${_formatNumber(secondOperand)} =';
          _calculate();
          _operator = null;
          _firstOperand = null;
          _shouldClearDisplay = true;
        }
      } else if (key == 'C' || key == 'Escape') {
        _display = '0';
        _firstOperand = null;
        _operator = null;
        _historyDisplay = '';
        _shouldClearDisplay = false;
      } else if (key == 'CE') {
        _display = '0';
        _shouldClearDisplay = false;
      } else if (key == 'Backspace') {
        if (_display == 'Error') return;   
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
      } else if (key == '+/-') {
        if (_display != '0' && _display != 'Error') {
          if (_display.startsWith('-')) {
            _display = _display.substring(1);
          } else {
            _display = '-$_display';
          }
        }
      } else if (key == '%') {
        final val = double.tryParse(_display);
        if (val != null) {
          if (_firstOperand != null && (_operator == '+' || _operator == '-')) {
            // Standard calculator percentage logic
            _display = _formatNumber((_firstOperand! * val) / 100);
          } else {
            _display = _formatNumber(val / 100);
          }
        }
      } else if (key == '1/x') {
        final val = double.tryParse(_display);
        if (val != null && val != 0) {
          _display = _formatNumber(1 / val);
          _shouldClearDisplay = true;
        } else {
          _display = 'Error';
        }
      } else if (key == 'x²') {
        final val = double.tryParse(_display);
        if (val != null) {
          _display = _formatNumber(val * val);
          _shouldClearDisplay = true;
        }
      } else if (key == '√x') {
        final val = double.tryParse(_display);
        if (val != null && val >= 0) {
          _display = _formatNumber(sqrt(val));
          _shouldClearDisplay = true;
        } else {
          _display = 'Error';
        }
      } else if (['MC', 'MR', 'M+', 'M-', 'MS'].contains(key)) {
        _handleMemory(key);
      } else {
        if (_display == 'Error') return;
        if (_shouldClearDisplay) {
          _display = key;
          _shouldClearDisplay = false;
        } else {
          if (_display == '0' && key != '.') {
            _display = key;
          } else {
            if (key == '.' && _display.contains('.')) return;
            _display += key;
          }
        }
      }
    });
  }

  void _handleMemory(String action) {
    if (_display == 'Error') return;
    final val = double.tryParse(_display) ?? 0.0;
    switch (action) {
      case 'MC':
        _memory = 0;
        break;
      case 'MR':
        _display = _formatNumber(_memory);
        _shouldClearDisplay = true;
        break;
      case 'M+':
        _memory += val;
        _shouldClearDisplay = true;
        break;
      case 'M-':
        _memory -= val;
        _shouldClearDisplay = true;
        break;
      case 'MS':
        _memory = val;
        _shouldClearDisplay = true;
        break;
    }
  }

  void _calculate() {
    if (_firstOperand == null || _operator == null) return;
    
    final secondOperand = double.tryParse(_display) ?? 0;
    double result = 0;
    
    switch (_operator) {
      case '+': result = _firstOperand! + secondOperand; break;
      case '-': result = _firstOperand! - secondOperand; break;
      case '×': result = _firstOperand! * secondOperand; break;
      case '÷': 
        if (secondOperand == 0) {
          _display = 'Error';
          _shouldClearDisplay = true;
          return;
        }
        result = _firstOperand! / secondOperand; 
        break;
    }
    
    _display = _formatNumber(result);
  }

  String _formatNumber(double? num) {
    if (num == null) return '';
    String res = num.toString();
    if (res.endsWith('.0')) {
      return res.substring(0, res.length - 2);
    }
    // Very simple rounding to prevent visual overflow for standard calc
    if (res.length > 12) {
      return num.toStringAsPrecision(10).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return res;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.numpad0 || key == LogicalKeyboardKey.digit0) { _onKeyPress('0'); }
      else if (key == LogicalKeyboardKey.numpad1 || key == LogicalKeyboardKey.digit1) { _onKeyPress('1'); }
      else if (key == LogicalKeyboardKey.numpad2 || key == LogicalKeyboardKey.digit2) { _onKeyPress('2'); }
      else if (key == LogicalKeyboardKey.numpad3 || key == LogicalKeyboardKey.digit3) { _onKeyPress('3'); }
      else if (key == LogicalKeyboardKey.numpad4 || key == LogicalKeyboardKey.digit4) { _onKeyPress('4'); }
      else if (key == LogicalKeyboardKey.numpad5 || key == LogicalKeyboardKey.digit5) { _onKeyPress('5'); }
      else if (key == LogicalKeyboardKey.numpad6 || key == LogicalKeyboardKey.digit6) { _onKeyPress('6'); }
      else if (key == LogicalKeyboardKey.numpad7 || key == LogicalKeyboardKey.digit7) { _onKeyPress('7'); }
      else if (key == LogicalKeyboardKey.numpad8 || key == LogicalKeyboardKey.digit8) { _onKeyPress('8'); }
      else if (key == LogicalKeyboardKey.numpad9 || key == LogicalKeyboardKey.digit9) { _onKeyPress('9'); }
      else if (key == LogicalKeyboardKey.numpadDecimal || key == LogicalKeyboardKey.period) { _onKeyPress('.'); }
      else if (key == LogicalKeyboardKey.numpadAdd || (key == LogicalKeyboardKey.equal && HardwareKeyboard.instance.isShiftPressed)) { _onKeyPress('+'); }
      else if (event.character == '+') { _onKeyPress('+'); }
      else if (key == LogicalKeyboardKey.numpadSubtract || key == LogicalKeyboardKey.minus) { _onKeyPress('-'); }
      else if (key == LogicalKeyboardKey.numpadMultiply || (key == LogicalKeyboardKey.digit8 && HardwareKeyboard.instance.isShiftPressed) || event.character == '*') { _onKeyPress('×'); }
      else if (key == LogicalKeyboardKey.numpadDivide || key == LogicalKeyboardKey.slash) { _onKeyPress('÷'); }
      else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter || (key == LogicalKeyboardKey.equal && !HardwareKeyboard.instance.isShiftPressed)) { _onKeyPress('='); }
      else if (key == LogicalKeyboardKey.backspace) { _onKeyPress('Backspace'); }
      else if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.delete) { _onKeyPress('C'); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        autofocus: true,
        child: Container(
          width: 380,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title bar (blue)
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: AppColors.tableHeaderBg,
                child: Row(
                  children: [
                    const Icon(Icons.calculate_outlined, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    const Text('Calculator', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, size: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // Menu & Top controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  children: [
                    const Text('Standard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const Spacer(),
                    Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(color: AppColors.surfaceBorder), borderRadius: BorderRadius.circular(2)), child: const Icon(Icons.push_pin_outlined, size: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              
              // Display Area
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 20,
                      child: Text(
                        _historyDisplay,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _display,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              // Memory Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMemoryButton('MC', _memory == 0),
                    _buildMemoryButton('MR', _memory == 0),
                    _buildMemoryButton('M+', false),
                    _buildMemoryButton('M-', false),
                    _buildMemoryButton('MS', false),
                    _buildMemoryButton('M^', _memory == 0, isIcon: true), 
                  ],
                ),
              ),

              // Standard Grid
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildCalcButton('%', isAction: true),
                        _buildCalcButton('CE', isAction: true),
                        _buildCalcButton('C', isAction: true),
                        _buildCalcButton('Backspace', icon: Icons.backspace_outlined, isAction: true),
                      ],
                    ),
                    Row(
                      children: [
                        _buildCalcButton('1/x', isAction: true),
                        _buildCalcButton('x²', isAction: true),
                        _buildCalcButton('√x', isAction: true),
                        _buildCalcButton('÷', isAction: true),
                      ],
                    ),
                    Row(
                      children: [
                        _buildCalcButton('7'),
                        _buildCalcButton('8'),
                        _buildCalcButton('9'),
                        _buildCalcButton('×', isAction: true),
                      ],
                    ),
                    Row(
                      children: [
                        _buildCalcButton('4'),
                        _buildCalcButton('5'),
                        _buildCalcButton('6'),
                        _buildCalcButton('-', isAction: true),
                      ],
                    ),
                    Row(
                      children: [
                        _buildCalcButton('1'),
                        _buildCalcButton('2'),
                        _buildCalcButton('3'),
                        _buildCalcButton('+', isAction: true),
                      ],
                    ),
                    Row(
                      children: [
                        _buildCalcButton('+/-'),
                        _buildCalcButton('0'),
                        _buildCalcButton('.'),
                        _buildCalcButton('=', isEquals: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryButton(String label, bool disabled, {bool isIcon = false}) {
    return InkWell(
      onTap: disabled ? null : () {
        _onKeyPress(label);
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: disabled ? Colors.black26 : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildCalcButton(String text, {IconData? icon, bool isAction = false, bool isEquals = false}) {
    Color bgColor = const Color(0xFFFAFAFA); // White for numbers
    if (isAction) bgColor = const Color(0xFFF3F3F3); // Light gray for actions
    if (isEquals) bgColor = const Color(0xFF005A9E); // Windows Blue

    Color fgColor = isEquals ? Colors.white : Colors.black87;

    return Expanded(
      child: Container(
        height: 52,
        margin: const EdgeInsets.all(2),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            hoverColor: fgColor.withValues(alpha: 0.05),
            onTap: () {
              _onKeyPress(text);
              FocusScope.of(context).requestFocus(_focusNode);
            },
            child: Center(
              child: icon != null
                ? Icon(icon, color: fgColor, size: 20)
                : Text(
                    text == 'x²' || text == '√x' || text == '1/x' ? text : text, // Just text rendering
                    style: TextStyle(
                      fontSize: (text == '1/x' || text == 'x²' || text == '√x' || text == 'CE' || text == 'C' || text == '%') ? 16 : 20,
                      fontWeight: (text == '=') ? FontWeight.w500 : FontWeight.w400,
                      color: fgColor,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
