import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';


class UploadPhotoWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? imageUrl;
  final double size;

  const UploadPhotoWidget({
    Key? key,
    this.onTap,
    this.imageUrl,
    this.size = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Icon(
                      Icons.cloud_upload_outlined,
                      size: size * 0.33,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Upload Photo',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

