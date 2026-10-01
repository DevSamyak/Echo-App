import 'dart:io';

import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/widgets/audiowave.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final songNameController = TextEditingController();
  final artistController = TextEditingController();
  Color selectedColor = Pallete.cardColor;
  File? selectedThumbnail;
  File? selectedAudio;
  final formKey = GlobalKey<FormState>();

  void selectAudio() async {
    final pickedAudio = await pickAudio();
    if (pickedAudio != null) {
      setState(() {
        selectedAudio = pickedAudio;
      });
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        selectedThumbnail = pickedImage;
      });
    }
  }

  @override
  void dispose() {
    songNameController.dispose();
    artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(homeViewmodelProvider.select((val) => val?.isLoading == true));

    // 1. ADD LISTENER TO HANDLE NAVIGATION AUTOMATICALLY
    ref.listen(homeViewmodelProvider, (_, next) {
      next?.when(
        data: (data) {
          showSnackBar(context, 'Song uploaded successfully!');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage(initialIndex: 2,)),
            (route) => false,
          );
        },
        error: (error, st) {
          showSnackBar(context, error.toString());
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Song'),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState!.validate() &&
                  selectedAudio != null &&
                  selectedThumbnail != null) {
                
                final hexCode = selectedColor.value
                    .toRadixString(16)
                    .substring(2, 8)
                    .toUpperCase();
                
                // 2. CALL VIEWMODEL INSTEAD OF REPOSITORY
                await ref.read(homeViewmodelProvider.notifier).uploadSong(
                      selectedThumbnail: selectedThumbnail!,
                      selectedAudio: selectedAudio!,
                      artist_name: artistController.text,
                      song_name: songNameController.text,
                      selectedColor: selectedColor,
                    );
              } else {
                showSnackBar(context, "Please fill all fields and select files!");
              }
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: selectImage,
                        child: selectedThumbnail != null
                            ? SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    selectedThumbnail!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : DottedBorder(
                                strokeCap: StrokeCap.round,
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                color: Pallete.borderColor,
                                dashPattern: const [10, 4],
                                child: const SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.folder_open, size: 40),
                                      SizedBox(height: 15),
                                      Text(
                                        'Select the thumbnail for your song',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 40),
                      selectedAudio != null
                          ? Audiowave(path: selectedAudio!.path)
                          : CustomField(
                              hinttext: 'Pick a Song',
                              controller: null,
                              readOnly: true,
                              onTap: selectAudio,
                            ),
                      const SizedBox(height: 20),
                      CustomField(
                        hinttext: 'Artist',
                        controller: artistController,
                      ),
                      const SizedBox(height: 20),
                      CustomField(
                        hinttext: 'Song name',
                        controller: songNameController,
                      ),
                      const SizedBox(height: 20),
                      // 3. COLOR PICKER FIX
                      ColorPicker(
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                        },
                        color: selectedColor,
                        enableShadesSelection: false, // Ensures direct selection registers
                        onColorChanged: (Color color) {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}