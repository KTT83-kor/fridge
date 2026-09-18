import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/core/theme/app_spacing.dart';
import 'package:fridge/domain/repository/ingredient_repository.dart';
import 'package:fridge/domain/repository/receipt_parsing_repository.dart';
import 'package:fridge/domain/repository/shelf_life_repository.dart';
import 'package:fridge/ui/quick_add/bloc/quick_add_bloc.dart';
import 'package:fridge/ui/quick_add/widget/quick_add_text_field.dart';
import 'package:fridge/ui/quick_add/widget/quick_ingredient_review_list.dart';
import 'package:fridge/ui/quick_add/widget/receipt_scan_button.dart';

class QuickAddPage extends StatelessWidget {
  const QuickAddPage({super.key});

  static Route<bool> route() {
    return MaterialPageRoute<bool>(builder: (context) => const QuickAddPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: _createBloc, child: const _QuickAddView());
  }

  QuickAddBloc _createBloc(BuildContext context) {
    return QuickAddBloc(
      ingredientRepository: context.read<IngredientRepository>(),
      shelfLifeRepository: context.read<ShelfLifeRepository>(),
      receiptParsingRepository: context.read<ReceiptParsingRepository>(),
      today: DateTime.now(),
    );
  }
}

class _QuickAddView extends StatelessWidget {
  const _QuickAddView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuickAddBloc, QuickAddState>(
      listenWhen: _hasStatusChanged,
      listener: _handleStatus,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.quickAddTitle)),
        body: const _QuickAddBody(),
        bottomNavigationBar: const _BottomBar(),
      ),
    );
  }

  bool _hasStatusChanged(QuickAddState previous, QuickAddState current) {
    return previous.status != current.status;
  }

  void _handleStatus(BuildContext context, QuickAddState state) {
    switch (state.status) {
      case QuickAddStatus.editing:
      case QuickAddStatus.parsing:
      case QuickAddStatus.reviewing:
      case QuickAddStatus.submitting:
        return;
      case QuickAddStatus.success:
        Navigator.of(context).pop(true);
      case QuickAddStatus.failure:
        final snackBar = SnackBar(content: Text(state.errorMessage));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

class _QuickAddBody extends StatelessWidget {
  const _QuickAddBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuickAddBloc, QuickAddState>(builder: _buildByStatus);
  }

  Widget _buildByStatus(BuildContext context, QuickAddState state) {
    switch (state.status) {
      case QuickAddStatus.editing:
        return const QuickAddTextField();
      case QuickAddStatus.parsing:
        return const _ReceiptScanningView();
      case QuickAddStatus.reviewing:
      case QuickAddStatus.submitting:
      case QuickAddStatus.success:
      case QuickAddStatus.failure:
        return QuickIngredientReviewList(
          drafts: state.drafts,
          today: DateTime.now(),
        );
    }
  }
}

class _ReceiptScanningView extends StatelessWidget {
  const _ReceiptScanningView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text(AppStrings.quickAddScanning),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuickAddBloc, QuickAddState>(builder: _buildByStatus);
  }

  Widget _buildByStatus(BuildContext context, QuickAddState state) {
    switch (state.status) {
      case QuickAddStatus.editing:
        return _ParseButton(canParse: state.canParse);
      case QuickAddStatus.parsing:
        return const SizedBox.shrink();
      case QuickAddStatus.reviewing:
      case QuickAddStatus.submitting:
      case QuickAddStatus.success:
      case QuickAddStatus.failure:
        return _ReviewActions(canSubmit: state.canSubmit);
    }
  }
}

class _ParseButton extends StatelessWidget {
  const _ParseButton({required this.canParse});

  final bool canParse;

  @override
  Widget build(BuildContext context) {
    void parse() {
      context.read<QuickAddBloc>().add(const QuickAddParsed());
    }

    final onPressed = canParse ? parse : null;

    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReceiptScanButton(),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSpacing.xl * 1.5),
            ),
            child: const Text(AppStrings.quickAddParse),
          ),
        ],
      ),
    );
  }
}

class _ReviewActions extends StatelessWidget {
  const _ReviewActions({required this.canSubmit});

  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    void goBack() {
      context.read<QuickAddBloc>().add(const QuickAddBackToEditing());
    }

    void submit() {
      context.read<QuickAddBloc>().add(const QuickAddSubmitted());
    }

    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: goBack,
              child: const Text(AppStrings.quickAddBack),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: canSubmit ? submit : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.xl * 1.5),
              ),
              child: const Text(AppStrings.quickAddSaveAll),
            ),
          ),
        ],
      ),
    );
  }
}
