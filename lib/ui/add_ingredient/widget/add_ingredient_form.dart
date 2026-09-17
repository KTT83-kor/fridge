import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/domain/entity/storage_place.dart';
import 'package:fridge/ui/add_ingredient/bloc/add_ingredient_bloc.dart';
import 'package:fridge/ui/add_ingredient/widget/date_picker_field.dart';
import 'package:fridge/ui/add_ingredient/widget/expiry_field.dart';
import 'package:fridge/ui/add_ingredient/widget/storage_place_selector.dart';

class AddIngredientForm extends StatefulWidget {
  const AddIngredientForm({super.key});

  @override
  State<AddIngredientForm> createState() => _AddIngredientFormState();
}

class _AddIngredientFormState extends State<AddIngredientForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitController = TextEditingController(text: AppStrings.defaultUnit);

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddIngredientBloc, AddIngredientState>(
      listenWhen: _hasUnitChanged,
      listener: _syncUnitController,
      builder: _buildForm,
    );
  }

  bool _hasUnitChanged(
    AddIngredientState previous,
    AddIngredientState current,
  ) {
    return previous.unit != current.unit;
  }

  void _syncUnitController(BuildContext context, AddIngredientState state) {
    if (_unitController.text == state.unit) return;
    _unitController.text = state.unit;
  }

  Widget _buildForm(BuildContext context, AddIngredientState state) {
    final bloc = context.read<AddIngredientBloc>();

    void changeName(String name) {
      bloc.add(AddIngredientNameChanged(name));
    }

    void changeAmount(String amount) {
      bloc.add(AddIngredientAmountChanged(amount));
    }

    void changeUnit(String unit) {
      bloc.add(AddIngredientUnitChanged(unit));
    }

    void changeStoragePlace(StoragePlace place) {
      bloc.add(AddIngredientStoragePlaceChanged(place));
    }

    void changePurchasedAt(DateTime purchasedAt) {
      bloc.add(AddIngredientPurchasedAtChanged(purchasedAt));
    }

    final nameField = _NameField(
      controller: _nameController,
      onChanged: changeName,
    );
    final amountField = _AmountAndUnitFields(
      amountController: _amountController,
      unitController: _unitController,
      onAmountChanged: changeAmount,
      onUnitChanged: changeUnit,
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        nameField,
        const SizedBox(height: AppSpacing.md),
        amountField,
        const SizedBox(height: AppSpacing.lg),
        StoragePlaceSelector(
          selected: state.storagePlace,
          onChanged: changeStoragePlace,
        ),
        const SizedBox(height: AppSpacing.lg),
        DatePickerField(
          label: AppStrings.purchasedAtLabel,
          value: state.purchasedAt,
          onChanged: changePurchasedAt,
        ),
        const SizedBox(height: AppSpacing.md),
        const ExpiryField(),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
      autofocus: true,
      decoration: const InputDecoration(
        labelText: AppStrings.ingredientName,
        hintText: AppStrings.ingredientNameHint,
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _AmountAndUnitFields extends StatelessWidget {
  const _AmountAndUnitFields({
    required this.amountController,
    required this.unitController,
    required this.onAmountChanged,
    required this.onUnitChanged,
  });

  static const _amountFlex = 2;

  final TextEditingController amountController;
  final TextEditingController unitController;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final amountFormatters = [
      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: _amountFlex,
          child: TextField(
            controller: amountController,
            onChanged: onAmountChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: amountFormatters,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: AppStrings.ingredientAmount,
              hintText: AppStrings.ingredientAmountHint,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TextField(
            controller: unitController,
            onChanged: onUnitChanged,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: AppStrings.ingredientUnit,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
