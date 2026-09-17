import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/ui/quick_add/bloc/quick_add_bloc.dart';

class QuickAddTextField extends StatefulWidget {
  const QuickAddTextField({super.key});

  @override
  State<QuickAddTextField> createState() => _QuickAddTextFieldState();
}

class _QuickAddTextFieldState extends State<QuickAddTextField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<QuickAddBloc>();

    void changeText(String text) {
      bloc.add(QuickAddTextChanged(text));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        controller: _controller,
        onChanged: changeText,
        maxLines: null,
        minLines: 8,
        autofocus: true,
        textInputAction: TextInputAction.newline,
        decoration: const InputDecoration(
          hintText: AppStrings.quickAddHint,
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
