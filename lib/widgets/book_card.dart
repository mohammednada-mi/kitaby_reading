import 'dart:io'; // For File operations
import 'package:flutter/material.dart';
import 'package:kitaby_flutter/models/book.dart';
import 'package:kitaby_flutter/providers/book_provider.dart';
import 'package:kitaby_flutter/utils/constants.dart'; // Import constants
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart'; // Import percent_indicator

class BookCard
    extends
        StatefulWidget {
  final Book
  book;
  final bool
  showEditCurrentPage;

  const BookCard({
    super.key,
    required this.book,
    this.showEditCurrentPage =
        false,
  });

  @override
  State<
    BookCard
  >
  createState() =>
      _BookCardState();
}

class _BookCardState
    extends
        State<
          BookCard
        > {
  bool
  _isEditingCurrentPage =
      false;
  late TextEditingController
  _currentPageController;
  final _formKey =
      GlobalKey<
        FormState
      >(); // For validation

  @override
  void
  initState() {
    super
        .initState();
    _currentPageController = TextEditingController(
      text:
          widget.book.currentPage.toString(),
    );
  }

  @override
  void
  dispose() {
    _currentPageController
        .dispose();
    super
        .dispose();
  }

  @override
  void
  didUpdateWidget(
    covariant BookCard
    oldWidget,
  ) {
    super.didUpdateWidget(
      oldWidget,
    );
    // Update controller if the book's current page changes from outside
    if (widget.book.currentPage !=
            oldWidget.book.currentPage &&
        !_isEditingCurrentPage) {
      _currentPageController.text =
          widget.book.currentPage.toString();
    }
  }

  // --- Helper Functions ---
  double
  get _progressValue {
    if (widget.book.totalPages <=
        0)
      return 0.0;
    double
    progress =
        widget.book.currentPage /
        widget.book.totalPages;
    return progress.clamp(
      0.0,
      1.0,
    ); // Clamp between 0.0 and 1.0
  }

  void
  _toggleEditMode() {
    setState(() {
      _isEditingCurrentPage =
          !_isEditingCurrentPage;
      if (!_isEditingCurrentPage) {
        // Reset controller if canceling edit
        _currentPageController.text = widget.book.currentPage.toString();
      }
    });
  }

  Future<
    void
  >
  _saveCurrentPage(
    BuildContext
    context,
  ) async {
    if (_formKey
        .currentState!
        .validate()) {
      final newPage = int.parse(
        _currentPageController.text,
      );
      final bookProvider = Provider.of<
        BookProvider
      >(
        context,
        listen:
            false,
      );
      try {
        await bookProvider.updateBookCurrentPage(
          widget.book.id,
          newPage,
        );
        setState(
          () {
            _isEditingCurrentPage =
                false;
          },
        ); // Exit edit mode on success
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'تم تحديث الصفحة الحالية.',
            ),
          ),
        );
      } catch (
        e
      ) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ أثناء تحديث الصفحة: $e',
            ),
          ),
        );
      }
    }
  }

  Future<
    void
  >
  _confirmDelete(
    BuildContext
    context,
  ) async {
    final bool?
    confirm = await showDialog<
      bool
    >(
      context:
          context,
      builder: (
        BuildContext
        context,
      ) {
        return AlertDialog(
          title: const Text(
            'تأكيد الحذف',
          ),
          content: Text(
            'هل أنت متأكد أنك تريد حذف كتاب "${widget.book.title}"؟',
          ),
          actions: <
            Widget
          >[
            TextButton(
              child: const Text(
                'إلغاء',
              ),
              onPressed:
                  () => Navigator.of(
                    context,
                  ).pop(
                    false,
                  ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(
                      context,
                    ).colorScheme.error,
              ),
              child: const Text(
                'حذف',
              ),
              onPressed:
                  () => Navigator.of(
                    context,
                  ).pop(
                    true,
                  ),
            ),
          ],
        );
      },
    );

    if (confirm ==
        true) {
      final bookProvider = Provider.of<
        BookProvider
      >(
        context,
        listen:
            false,
      );
      try {
        await bookProvider.deleteBook(
          widget.book.id,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف كتاب "${widget.book.title}" بنجاح.',
            ),
          ),
        );
      } catch (
        e
      ) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ أثناء الحذف: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    final theme = Theme.of(
      context,
    );
    final colorScheme =
        theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical:
            AppConstants.spacingSmall,
        horizontal:
            0,
      ), // Adjust margin
      elevation:
          2, // Add subtle elevation
      child: IntrinsicHeight(
        // Ensure Row children have same height potential
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Cover Image
            Container(
              width:
                  80, // Fixed width for the image container
              height:
                  120, // Fixed height for the image container
              margin: const EdgeInsets.all(
                AppConstants.paddingMedium,
              ),
              decoration: BoxDecoration(
                color:
                    Colors.grey[200], // Placeholder background
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
              child: ClipRRect(
                // Clip the image to the rounded corners
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
                child:
                    widget.book.coverImagePath !=
                            null
                        ? Image.file(
                          File(
                            widget.book.coverImagePath!,
                          ),
                          fit:
                              BoxFit.cover, // Cover the container bounds
                          errorBuilder:
                              (
                                context,
                                error,
                                stackTrace,
                              ) => const Icon(
                                Icons.broken_image,
                                color:
                                    Colors.grey,
                              ),
                        )
                        : const Icon(
                          Icons.book_outlined,
                          color:
                              Colors.grey,
                          size:
                              40,
                        ), // Placeholder icon
              ),
            ),

            // Book Details and Actions
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  AppConstants.paddingMedium,
                  AppConstants.paddingMedium,
                  AppConstants.paddingSmall,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Space out elements vertically
                  children: [
                    // Top section: Title and Author
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                          maxLines:
                              2,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height:
                              AppConstants.spacingXSmall,
                        ),
                        Text(
                          widget.book.author,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                colorScheme.secondary,
                          ), // Use secondary color or muted
                          maxLines:
                              1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Middle section: Progress Bar and Page Info
                    if (!_isEditingCurrentPage)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical:
                              AppConstants.spacingSmall,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            LinearPercentIndicator(
                              padding:
                                  EdgeInsets.zero, // Remove padding
                              percent:
                                  _progressValue,
                              lineHeight:
                                  8.0,
                              backgroundColor: colorScheme.secondary.withOpacity(
                                0.3,
                              ),
                              progressColor:
                                  colorScheme.primary, // Use primary color
                              barRadius: const Radius.circular(
                                4,
                              ),
                            ),
                            const SizedBox(
                              height:
                                  AppConstants.spacingXSmall /
                                  2,
                            ),
                            Text(
                              'الصفحة ${widget.book.currentPage} / ${widget.book.totalPages}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Edit Current Page Form
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical:
                              AppConstants.spacingSmall,
                        ),
                        child: Form(
                          key:
                              _formKey,
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      _currentPageController,
                                  keyboardType:
                                      TextInputType.number,
                                  decoration: InputDecoration(
                                    isDense:
                                        true, // Make input smaller
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal:
                                          8,
                                      vertical:
                                          8,
                                    ),
                                    hintText:
                                        'الصفحة',
                                    border:
                                        const OutlineInputBorder(),
                                    errorStyle: const TextStyle(
                                      height:
                                          0.1,
                                    ), // Reduce error message space
                                  ),
                                  validator: (
                                    value,
                                  ) {
                                    if (value ==
                                            null ||
                                        value.isEmpty)
                                      return ''; // Just show red border
                                    final page = int.tryParse(
                                      value,
                                    );
                                    if (page ==
                                            null ||
                                        page <
                                            0 ||
                                        page >
                                            widget.book.totalPages)
                                      return '';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                width:
                                    AppConstants.spacingSmall,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  size:
                                      20,
                                ),
                                onPressed:
                                    () => _saveCurrentPage(
                                      context,
                                    ),
                                tooltip:
                                    'حفظ',
                                visualDensity:
                                    VisualDensity.compact,
                                padding:
                                    EdgeInsets.zero,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size:
                                      20,
                                ),
                                onPressed:
                                    _toggleEditMode, // Cancel edit
                                tooltip:
                                    'إلغاء',
                                visualDensity:
                                    VisualDensity.compact,
                                padding:
                                    EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Bottom section: Actions
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        if (widget.showEditCurrentPage &&
                            !_isEditingCurrentPage)
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size:
                                  20,
                            ),
                            tooltip:
                                'تعديل الصفحة الحالية',
                            onPressed:
                                _toggleEditMode,
                            visualDensity:
                                VisualDensity.compact, // Make icon button smaller
                            padding: const EdgeInsets.all(
                              4,
                            ), // Adjust padding
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size:
                                20,
                            color:
                                colorScheme.error,
                          ),
                          tooltip:
                              'حذف الكتاب',
                          onPressed:
                              () => _confirmDelete(
                                context,
                              ),
                          visualDensity:
                              VisualDensity.compact,
                          padding: const EdgeInsets.all(
                            4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
