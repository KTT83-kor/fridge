import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fridge/core/constant/app_strings.dart';
import 'package:fridge/ui/quick_add/bloc/quick_add_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptScanButton extends StatelessWidget {
  ReceiptScanButton({super.key, ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<QuickAddBloc>();

    Future<void> pickImage() async {
      final photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo == null) return;

      final imageBytes = await photo.readAsBytes();
      bloc.add(QuickAddReceiptImagePicked(imageBytes));
    }

    return OutlinedButton.icon(
      onPressed: pickImage,
      icon: const Icon(Icons.camera_alt_outlined),
      label: const Text(AppStrings.quickAddScanReceipt),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}
