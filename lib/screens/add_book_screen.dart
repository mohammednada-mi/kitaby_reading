import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:image_picker/image_picker.dart'; // For image picking
import 'package:kitaby_flutter/models/book.dart';
import 'package:kitaby_flutter/providers/book_provider.dart';
import 'package:kitaby_flutter/services/local_storage_service.dart'; // Import service for saving image
import 'package:kitaby_flutter/utils/constants.dart'; // Import constants
import 'package:kitaby_flutter/widgets/app_drawer.dart'; // Import AppDrawer
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

class AddBookScreen
    extends
        StatefulWidget {
  const AddBookScreen({
    super.key,
  });

  @override
  State<
    AddBookScreen
  >
  createState() =>
      _AddBookScreenState();
}

class _AddBookScreenState
    extends
        State<
          AddBookScreen
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _localStorageService =
      LocalStorageService(); // Instance for image saving
  final _uuid =
      const Uuid(); // Instance for ID generation

  // Form field controllers
  final _titleController =
      TextEditingController();
  final _authorController =
      TextEditingController();
  final _totalPagesController =
      TextEditingController();
  final _currentPageController = TextEditingController(
    text:
        '0',
  ); // Default to 0
  final _descriptionController =
      TextEditingController();

  BookCategory?
  _selectedCategory;
  File?
  _coverImageFile; // To hold the selected image file
  String?
  _coverImagePreviewPath; // To display the selected image
  bool
  _isSubmitting =
      false;

  @override
  void
  dispose() {
    // Dispose controllers
    _titleController
        .dispose();
    _authorController
        .dispose();
    _totalPagesController
        .dispose();
    _currentPageController
        .dispose();
    _descriptionController
        .dispose();
    super
        .dispose();
  }

  // --- Image Picking Logic ---
  Future<
    void
  >
  _pickImage() async {
    if (_isSubmitting)
      return; // Prevent picking while submitting

    final ImagePicker
    picker =
        ImagePicker();
    try {
      final XFile?
      image = await picker.pickImage(
        source:
            ImageSource.gallery,
        maxWidth:
            1024,
        maxHeight:
            1024,
        imageQuality:
            85,
      );

      if (image !=
          null) {
        final file = File(
          image.path,
        );
        final size = await file.length();
        
        if (size >
                5 *
                    1024 *
                    1024) { // 5MB limit
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'حجم الصورة كبير جداً. الحد الأقصى هو 5 ميجابايت',
              ),
              duration: Duration(
                seconds:
                    3,
              ),
            ),
          );
          return;
        }

        setState(
          () {
            _coverImageFile = file;
            _coverImagePreviewPath =
                image.path; // Use path for preview
          },
        );
      }
    } catch (
      e
    ) {
      // Handle potential errors during image picking (e.g., permissions)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء اختيار الصورة: ${e.toString()}',
          ),
          duration: const Duration(
            seconds:
                3,
          ),
        ),
      );
    }
  }

  // --- Form Submission Logic ---
  Future<
    void
  >
  _submitForm() async {
    // Hide keyboard
    FocusScope.of(
      context,
    ).unfocus();

    if (_formKey
        .currentState!
        .validate()) {
      setState(
        () =>
            _isSubmitting =
                true,
      );

      final bookProvider = Provider.of<
        BookProvider
      >(
        context,
        listen:
            false,
      );
      final String
      bookId =
          'book_${_uuid.v4()}'; // Generate unique ID

      String?
      savedImagePath;
      // Save image if selected
      if (_coverImageFile !=
          null) {
        try {
          savedImagePath = await _localStorageService.saveCoverImage(
            _coverImageFile!,
            bookId,
          );
          if (savedImagePath ==
              null) {
            throw Exception(
                'فشل حفظ صورة الغلاف');
          }
        } catch (
          e
        ) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                'حدث خطأ أثناء حفظ صورة الغلاف: ${e.toString()}',
              ),
              duration: const Duration(
                seconds:
                    3,
              ),
            ),
          );
          setState(
            () =>
                _isSubmitting =
                    false,
          );
          return; // Stop submission if image saving failed
        }
      }

      // Create the Book object
      final newBook = Book(
        id:
            bookId,
        title:
            _titleController.text.trim(),
        author:
            _authorController.text.trim(),
        totalPages: int.parse(
          _totalPagesController.text,
        ),
        currentPage:
            int.tryParse(
              _currentPageController.text,
            ) ??
            0,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        category:
            _selectedCategory!, // Validation ensures this is not null
        coverImagePath:
            savedImagePath, // Use the saved path
      );

      try {
        await bookProvider.addBook(
          newBook,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                'تمت إضافة كتاب "${newBook.title}" بنجاح.',
              ),
              duration: Duration(
                seconds:
                    2,
              ),
            ),
          );
          // Navigate back after successful submission
          Navigator.pop(
            context,
          );
        }
      } catch (
        e
      ) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                'حدث خطأ أثناء إضافة الكتاب: ${e.toString()}',
              ),
              duration: const Duration(
                seconds:
                    3,
              ),
            ),
          );
          // Keep submitting state false on error
          setState(
            () =>
                _isSubmitting =
                    false,
          );
        }
      }
      // No finally block needed here as navigation pops the screen
    }
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    final textTheme =
        Theme.of(
          context,
        ).textTheme;
    final colorScheme =
        Theme.of(
          context,
        ).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إضافة كتاب جديد',
        ),
      ),
      drawer:
          const AppDrawer(), // Add drawer if needed consistently
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          AppConstants.paddingLarge,
        ),
        child: Form(
          key:
              _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Make buttons full width potentially
            children: [
              // Title
              TextFormField(
                controller:
                    _titleController,
                decoration: const InputDecoration(
                  labelText:
                      'اسم الكتاب *',
                ),
                textInputAction:
                    TextInputAction.next, // Move to next field on keyboard
                validator:
                    (
                      value,
                    ) =>
                        value ==
                                    null ||
                                value.trim().isEmpty
                            ? 'اسم الكتاب مطلوب.'
                            : null,
              ),
              const SizedBox(
                height:
                    AppConstants.spacingMedium,
              ),

              // Author
              TextFormField(
                controller:
                    _authorController,
                decoration: const InputDecoration(
                  labelText:
                      'اسم المؤلف *',
                ),
                textInputAction:
                    TextInputAction.next,
                validator:
                    (
                      value,
                    ) =>
                        value ==
                                    null ||
                                value.trim().isEmpty
                            ? 'اسم المؤلف مطلوب.'
                            : null,
              ),
              const SizedBox(
                height:
                    AppConstants.spacingMedium,
              ),

              // --- Pages Row ---
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align validators top
                children: [
                  // Total Pages
                  Expanded(
                    child: TextFormField(
                      controller:
                          _totalPagesController,
                      decoration: const InputDecoration(
                        labelText:
                            'عدد الصفحات *',
                      ),
                      keyboardType:
                          TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction:
                          TextInputAction.next,
                      validator: (
                        value,
                      ) {
                        if (value ==
                                null ||
                            value.isEmpty)
                          return 'مطلوب.'; // Short error
                        final pages = int.tryParse(
                          value,
                        );
                        if (pages ==
                                null ||
                            pages <=
                                0)
                          return 'غير صالح.'; // Short error
                        return null;
                      },
                      // Recalculate validation for current page when total pages change
                      onChanged:
                          (
                            _,
                          ) =>
                              _formKey.currentState?.validate(),
                    ),
                  ),
                  const SizedBox(
                    width:
                        AppConstants.spacingMedium,
                  ),
                  // Current Page
                  Expanded(
                    child: TextFormField(
                      controller:
                          _currentPageController,
                      decoration: const InputDecoration(
                        labelText:
                            'الصفحة الحالية',
                      ),
                      keyboardType:
                          TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction:
                          TextInputAction.next,
                      validator: (
                        value,
                      ) {
                        // Optional field allows empty or null
                        if (value ==
                                null ||
                            value.isEmpty) {
                          // Ensure controller reflects 0 if empty
                          // Future.delayed(Duration.zero, () => _currentPageController.text = '0');
                          return null;
                        }

                        final currentPage = int.tryParse(
                          value,
                        );
                        final totalPages = int.tryParse(
                          _totalPagesController.text,
                        ); // Get current total pages

                        if (currentPage ==
                                null ||
                            currentPage <
                                0) {
                          return 'غير صالح.'; // Short error
                        }
                        // Check against total pages ONLY if total pages is valid
                        if (totalPages !=
                                null &&
                            totalPages >
                                0 &&
                            currentPage >
                                totalPages) {
                          return '> الإجمالي'; // Short error
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height:
                    AppConstants.spacingMedium,
              ),

              // Description
              TextFormField(
                controller:
                    _descriptionController,
                decoration: const InputDecoration(
                  labelText:
                      'وصف مختصر (اختياري)',
                ),
                maxLines:
                    3,
                textInputAction:
                    TextInputAction.done, // Last text field
                onFieldSubmitted:
                    (
                      _,
                    ) =>
                        _submitForm(), // Submit on keyboard done
              ),
              const SizedBox(
                height:
                    AppConstants.spacingMedium,
              ),

              // Category Dropdown
              DropdownButtonFormField<
                BookCategory
              >(
                value:
                    _selectedCategory,
                hint: const Text(
                  'اختر التصنيف... *',
                ),
                decoration: const InputDecoration(
                  labelText:
                      'التصنيف *',
                ),
                items:
                    BookCategory.values.map(
                      (
                        BookCategory category,
                      ) {
                        return DropdownMenuItem<
                          BookCategory
                        >(
                          value:
                              category,
                          child: Text(
                            AppConstants.categoryDisplayNames[category] ??
                                category.name,
                          ), // Use display names
                        );
                      },
                    ).toList(),
                onChanged: (
                  BookCategory? newValue,
                ) {
                  setState(
                    () {
                      _selectedCategory =
                          newValue;
                    },
                  );
                },
                // Add focus node if needed for keyboard navigation
                validator:
                    (
                      value,
                    ) =>
                        value ==
                                null
                            ? 'يرجى تحديد التصنيف.'
                            : null,
              ),
              const SizedBox(
                height:
                    AppConstants.spacingMedium,
              ),

              // --- Cover Image Section ---
              Text(
                'صورة الغلاف (اختياري)',
                style: textTheme.labelLarge?.copyWith(
                  color:
                      colorScheme.secondary,
                ),
              ),
              const SizedBox(
                height:
                    AppConstants.spacingSmall,
              ),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // Align button with bottom of preview
                children: [
                  // Image Preview or Placeholder
                  Container(
                    width:
                        60,
                    height:
                        90,
                    decoration: BoxDecoration(
                      color:
                          Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusSmall,
                      ),
                      border: Border.all(
                        color:
                            Colors.grey.shade300,
                      ),
                      image:
                          _coverImagePreviewPath !=
                                  null
                              ? DecorationImage(
                                image: FileImage(
                                  File(
                                    _coverImagePreviewPath!,
                                  ),
                                ),
                                fit:
                                    BoxFit.cover,
                                onError: (
                                  exception,
                                  stackTrace,
                                ) {
                                  // Optionally show an error icon in the container
                                  debugPrint(
                                    "Error loading preview image: $exception",
                                  );
                                },
                              )
                              : null, // No image if path is null
                    ),
                    // Show placeholder icon only if path is null
                    child:
                        _coverImagePreviewPath ==
                                null
                            ? const Icon(
                              Icons.photo_size_select_actual_outlined,
                              color:
                                  Colors.grey,
                              size:
                                  30,
                            )
                            : null,
                  ),
                  const SizedBox(
                    width:
                        AppConstants.spacingMedium,
                  ),
                  // Upload Button
                  OutlinedButton.icon(
                    icon: const Icon(
                      Icons.upload_file_outlined,
                      size:
                          18,
                    ),
                    label: const Text(
                      'رفع صورة',
                    ),
                    onPressed:
                        _pickImage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal:
                            AppConstants.paddingMedium,
                        vertical:
                            AppConstants.paddingSmall,
                      ),
                      textStyle:
                          textTheme.labelMedium, // Adjust text style
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height:
                    AppConstants.spacingLarge *
                    1.5,
              ), // More space before buttons
              // --- Action Buttons ---
              ElevatedButton.icon(
                icon:
                    _isSubmitting
                        ? Container(
                          // Loading indicator
                          width:
                              20,
                          height:
                              20,
                          margin: const EdgeInsetsDirectional.only(
                            end:
                                AppConstants.spacingSmall,
                          ), // Add margin for loading indicator
                          child: CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                colorScheme.onPrimary,
                          ),
                        )
                        : const Icon(
                          Icons.save_outlined,
                        ),
                label: Text(
                  _isSubmitting
                      ? 'جاري الحفظ...'
                      : 'حفظ الكتاب',
                ),
                onPressed:
                    _isSubmitting
                        ? null
                        : _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    45,
                  ),
                ), // Make button taller
              ),
              const SizedBox(
                height:
                    AppConstants.spacingSmall,
              ),
              // Cancel Button
              TextButton(
                child: const Text(
                  'إلغاء',
                ),
                onPressed:
                    _isSubmitting
                        ? null
                        : () => Navigator.pop(
                          context,
                        ),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    40,
                  ),
                ), // Consistent height
              ),
            ],
          ),
        ),
      ),
    );
  }
}
