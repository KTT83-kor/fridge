import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/domain/entity/ingredient.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/domain/repository/shelf_life_repository.dart';
import 'package:fridge/ui/add_ingredient/bloc/add_ingredient_bloc.dart';
import 'package:fridge/ui/add_ingredient/widget/add_ingredient_form.dart';

class AddIngredientPage extends StatelessWidget {
  const AddIngredientPage({this.initial, super.key});

  final Ingredient? initial;

  static Route<bool> route({Ingredient? initial}) {
    return MaterialPageRoute<bool>(
      builder: (context) => AddIngredientPage(initial: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: _createBloc, child: const _AddIngredientView());
  }

  AddIngredientBloc _createBloc(BuildContext context) {
    return AddIngredientBloc(
      ingredientRepository: context.read<IngredientRepository>(),
      shelfLifeRepository: context.read<ShelfLifeRepository>(),
      today: DateTime.now(),
      initial: initial,
    );
  }
}

class _AddIngredientView extends StatelessWidget {
  const _AddIngredientView();

  @override
  Widget build(BuildContext context) {
    final isEditing = context.select(
      (AddIngredientBloc bloc) => bloc.state.isEditing,
    );
    final title = isEditing
        ? AppStrings.editIngredientTitle
        : AppStrings.addIngredientTitle;

    return BlocListener<AddIngredientBloc, AddIngredientState>(
      listenWhen: _hasStatusChanged,
      listener: _handleStatus,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const SafeArea(child: AddIngredientForm()),
        bottomNavigationBar: const _SaveButton(),
      ),
    );
  }

  bool _hasStatusChanged(
    AddIngredientState previous,
    AddIngredientState current,
  ) {
    return previous.status != current.status;
  }

  void _handleStatus(BuildContext context, AddIngredientState state) {
    switch (state.status) {
      case AddIngredientStatus.editing:
      case AddIngredientStatus.submitting:
        return;
      case AddIngredientStatus.success:
        Navigator.of(context).pop(true);
      case AddIngredientStatus.failure:
        final snackBar = SnackBar(content: Text(state.errorMessage));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddIngredientBloc, AddIngredientState>(
      builder: _buildButton,
    );
  }

  Widget _buildButton(BuildContext context, AddIngredientState state) {
    void submit() {
      context.read<AddIngredientBloc>().add(const AddIngredientSubmitted());
    }

    final onPressed = state.canSubmit ? submit : null;
    final label = state.isEditing ? AppStrings.saveEdit : AppStrings.save;

    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.md),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.xl * 1.5),
        ),
        child: Text(label),
      ),
    );
  }
}
