import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _dobFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Dino Silva Sauro');
    _phoneController = TextEditingController(text: '4002 8922');
    _emailController = TextEditingController(text: 'DinoSSauro@teste.com');
    _dobController = TextEditingController(text: 'DD / MM /YYY');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _dobFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(29, 0, 0, 0),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: colorScheme.secondary,
                            size: 28,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                          child: Text(
                            'Perfil',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.secondary,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.settings_sharp,
                            color: colorScheme.onSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 106,
                          height: 106,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/images/icon.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.person,
                                    size: 50,
                                    color: colorScheme.onSurfaceVariant),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              75, 75, 0, 0),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mode_edit_outlined,
                              color: colorScheme.onSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildInputField(
                  context,
                  label: 'Nome',
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                ),
                _buildInputField(
                  context,
                  label: 'Telefone',
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                ),
                _buildInputField(
                  context,
                  label: 'Email',
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                ),
                _buildInputField(
                  context,
                  label: 'Data de nascimento',
                  controller: _dobController,
                  focusNode: _dobFocusNode,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 70, 0, 30),
                  child: SizedBox(
                    width: 204,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.tertiary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Atualizar Perfil',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onTertiary,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(30, 24, 0, 10),
          child: Text(
            label,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
              fontSize: 24,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
          child: Container(
            width: double.infinity,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFECF1FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.surfaceContainerHighest,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
