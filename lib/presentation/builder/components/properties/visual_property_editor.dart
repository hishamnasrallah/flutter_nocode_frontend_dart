// lib/presentation/builder/components/properties/visual_property_editor.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/app_widget.dart';

class VisualPropertyEditor extends StatefulWidget {
  final AppWidget? widget;
  final Function(String, dynamic)? onPropertyChanged;
  final VoidCallback? onClose;

  const VisualPropertyEditor({
    super.key,
    required this.widget,
    this.onPropertyChanged,
    this.onClose,
  });

  @override
  State<VisualPropertyEditor> createState() => _VisualPropertyEditorState();
}

class _VisualPropertyEditorState extends State<VisualPropertyEditor>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _propertyValues = {};

  // Predefined style presets
  final List<Map<String, dynamic>> _textPresets = [
    {'name': 'Heading', 'fontSize': 24.0, 'fontWeight': 'bold'},
    {'name': 'Subheading', 'fontSize': 18.0, 'fontWeight': 'w600'},
    {'name': 'Body', 'fontSize': 14.0, 'fontWeight': 'normal'},
    {'name': 'Caption', 'fontSize': 12.0, 'fontWeight': 'normal'},
  ];

  final List<Map<String, dynamic>> _colorPresets = [
    {'name': 'Primary', 'color': AppColors.primary},
    {'name': 'Success', 'color': AppColors.success},
    {'name': 'Warning', 'color': AppColors.warning},
    {'name': 'Error', 'color': AppColors.error},
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeProperties();
  }

  void _initializeProperties() {
    if (widget.widget?.properties != null) {
      for (var property in widget.widget!.properties!) {
        final key = property.propertyName;
        _propertyValues[key] = property.effectiveValue;

        if (property.propertyType == 'string' ||
            property.propertyType == 'integer' ||
            property.propertyType == 'decimal') {
          _controllers[key] = TextEditingController(
            text: property.effectiveValue?.toString() ?? '',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.widget == null) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBasicProperties(),
              _buildStyleProperties(),
              _buildAdvancedProperties(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.touch_app,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select a Widget',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click any widget on the canvas\nto edit its properties',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getWidgetIcon(widget.widget!.widgetType),
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.widget!.widgetType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.widget!.widgetId != null)
                  Text(
                    '#${widget.widget!.widgetId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: widget.onClose,
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'Basic'),
          Tab(text: 'Style'),
          Tab(text: 'Advanced'),
        ],
      ),
    );
  }

  Widget _buildBasicProperties() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.widget!.widgetType == 'Text') ...[
          _buildTextInput('Text Content', 'text', 'Enter your text here'),
          const SizedBox(height: 16),
          _buildTextPresets(),
        ],

        if (widget.widget!.widgetType == 'ElevatedButton' ||
            widget.widget!.widgetType == 'TextButton') ...[
          _buildTextInput('Button Text', 'text', 'Button Label'),
          const SizedBox(height: 16),
          _buildActionSelector('On Click', 'onPressed'),
        ],

        if (widget.widget!.widgetType == 'TextField') ...[
          _buildTextInput('Label', 'labelText', 'Field Label'),
          const SizedBox(height: 12),
          _buildTextInput('Hint', 'hintText', 'Placeholder text'),
          const SizedBox(height: 12),
          _buildTextInput('Helper', 'helperText', 'Helper text below field'),
          const SizedBox(height: 12),
          _buildSwitch('Password Field', 'obscureText'),
        ],

        if (widget.widget!.widgetType == 'Image') ...[
          _buildImagePicker('imageUrl'),
          const SizedBox(height: 16),
          _buildImageFitSelector('fit'),
        ],

        if (widget.widget!.widgetType == 'Container') ...[
          _buildSizeControls(),
          const SizedBox(height: 16),
          _buildPaddingControls(),
        ],

        if (widget.widget!.widgetType == 'Column' ||
            widget.widget!.widgetType == 'Row') ...[
          _buildAlignmentControls(),
        ],
      ],
    );
  }

  Widget _buildStyleProperties() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_hasColorProperty()) ...[
          _buildSectionTitle('Colors'),
          _buildColorPicker('Background', 'backgroundColor'),
          const SizedBox(height: 12),
          if (widget.widget!.widgetType == 'Text')
            _buildColorPicker('Text Color', 'color'),
        ],

        if (_hasBorderProperty()) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Border'),
          _buildBorderControls(),
        ],

        if (_hasShadowProperty()) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Shadow'),
          _buildShadowControls(),
        ],

        if (_hasTypographyProperty()) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Typography'),
          _buildTypographyControls(),
        ],
      ],
    );
  }

  Widget _buildAdvancedProperties() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTextInput('Widget ID', 'widgetId', 'unique_identifier'),
        const SizedBox(height: 16),

        if (_hasConstraintsProperty()) ...[
          _buildSectionTitle('Constraints'),
          _buildConstraintControls(),
          const SizedBox(height: 16),
        ],

        if (_hasTransformProperty()) ...[
          _buildSectionTitle('Transform'),
          _buildTransformControls(),
          const SizedBox(height: 16),
        ],

        _buildSectionTitle('Visibility'),
        _buildSwitch('Visible', 'visible', defaultValue: true),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextInput(String label, String propertyName, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[propertyName] ??
              TextEditingController(text: _propertyValues[propertyName]?.toString() ?? ''),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            _updateProperty(propertyName, 'string', value);
          },
        ),
      ],
    );
  }

  Widget _buildTextPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Styles',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _textPresets.map((preset) {
            return ActionChip(
              label: Text(preset['name']),
              onPressed: () {
                _updateProperty('fontSize', 'decimal', preset['fontSize']);
                _updateProperty('fontWeight', 'string', preset['fontWeight']);
              },
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: const TextStyle(fontSize: 12),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorPicker(String label, String propertyName) {
    final currentColor = _propertyValues[propertyName] ?? Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Color presets
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _colorPresets.length + 1,
            itemBuilder: (context, index) {
              if (index == _colorPresets.length) {
                // Custom color picker
                return InkWell(
                  onTap: () => _showColorPicker(propertyName),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.colorize, size: 20),
                  ),
                );
              }

              final preset = _colorPresets[index];
              return InkWell(
                onTap: () {
                  _updateProperty(propertyName, 'color',
                    '#${preset['color'].value.toRadixString(16).substring(2)}');
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: preset['color'],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, String propertyName, {bool defaultValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Switch(
          value: _propertyValues[propertyName] ?? defaultValue,
          onChanged: (value) {
            _updateProperty(propertyName, 'boolean', value);
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildImagePicker(String propertyName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image Source',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controllers[propertyName] ??
                    TextEditingController(text: _propertyValues[propertyName]?.toString() ?? ''),
                decoration: InputDecoration(
                  hintText: 'Enter image URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (value) {
                  _updateProperty(propertyName, 'url', value);
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // TODO: Open image picker
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.photo_library),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageFitSelector(String propertyName) {
    final fits = ['cover', 'contain', 'fill', 'fitWidth', 'fitHeight'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image Fit',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: fits.map((fit) => ButtonSegment(
            value: fit,
            label: Text(fit, style: const TextStyle(fontSize: 11)),
          )).toList(),
          selected: {_propertyValues['fit'] ?? 'cover'},
          onSelectionChanged: (value) {
            _updateProperty(propertyName, 'string', value.first);
          },
        ),
      ],
    );
  }

  Widget _buildSizeControls() {
    return Row(
      children: [
        Expanded(
          child: _buildNumberInput('Width', 'width'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberInput('Height', 'height'),
        ),
      ],
    );
  }

  Widget _buildNumberInput(String label, String propertyName, {bool allowDecimal = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[propertyName] ??
              TextEditingController(text: _propertyValues[propertyName]?.toString() ?? ''),
          keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
          inputFormatters: [
            if (allowDecimal)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            final numValue = allowDecimal
                ? double.tryParse(value)
                : int.tryParse(value);
            _updateProperty(
              propertyName,
              allowDecimal ? 'decimal' : 'integer',
              numValue,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaddingControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Padding',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildNumberInput('All', 'padding'),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.settings, size: 20),
              onPressed: () {
                // TODO: Show individual padding controls
              },
              tooltip: 'Individual sides',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlignmentControls() {
    final isColumn = widget.widget!.widgetType == 'Column';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAlignmentSelector(
          isColumn ? 'Vertical Alignment' : 'Horizontal Alignment',
          'mainAxisAlignment',
          ['start', 'center', 'end', 'spaceBetween', 'spaceAround', 'spaceEvenly'],
        ),
        const SizedBox(height: 12),
        _buildAlignmentSelector(
          isColumn ? 'Horizontal Alignment' : 'Vertical Alignment',
          'crossAxisAlignment',
          ['start', 'center', 'end', 'stretch'],
        ),
      ],
    );
  }

  Widget _buildAlignmentSelector(String label, String propertyName, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _propertyValues[propertyName] ?? options.first,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Row(
                children: [
                  Icon(_getAlignmentIcon(option), size: 16),
                  const SizedBox(width: 8),
                  Text(option),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            _updateProperty(propertyName, 'string', value);
          },
        ),
      ],
    );
  }

  Widget _buildActionSelector(String label, String propertyName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            // TODO: Show action selector dialog
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.flash_on, size: 20, color: AppColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _propertyValues[propertyName]?.toString() ?? 'Select action',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBorderControls() {
    return Column(
      children: [
        _buildNumberInput('Border Width', 'borderWidth'),
        const SizedBox(height: 12),
        _buildColorPicker('Border Color', 'borderColor'),
        const SizedBox(height: 12),
        _buildNumberInput('Border Radius', 'borderRadius'),
      ],
    );
  }

  Widget _buildShadowControls() {
    return Column(
      children: [
        _buildSwitch('Enable Shadow', 'hasShadow'),
        if (_propertyValues['hasShadow'] == true) ...[
          const SizedBox(height: 12),
          _buildNumberInput('Shadow Blur', 'shadowBlur'),
          const SizedBox(height: 12),
          _buildColorPicker('Shadow Color', 'shadowColor'),
        ],
      ],
    );
  }

  Widget _buildTypographyControls() {
    return Column(
      children: [
        _buildNumberInput('Font Size', 'fontSize'),
        const SizedBox(height: 12),
        _buildFontWeightSelector(),
        const SizedBox(height: 12),
        _buildTextAlignSelector(),
      ],
    );
  }

  Widget _buildFontWeightSelector() {
    final weights = [
      {'label': 'Light', 'value': 'w300'},
      {'label': 'Normal', 'value': 'normal'},
      {'label': 'Medium', 'value': 'w500'},
      {'label': 'Bold', 'value': 'bold'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Font Weight',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: weights.map((weight) => ButtonSegment(
            value: weight['value']!,
            label: Text(weight['label']!, style: const TextStyle(fontSize: 11)),
          )).toList(),
          selected: {_propertyValues['fontWeight'] ?? 'normal'},
          onSelectionChanged: (value) {
            _updateProperty('fontWeight', 'string', value.first);
          },
        ),
      ],
    );
  }

  Widget _buildTextAlignSelector() {
    final aligns = [
      {'icon': Icons.format_align_left, 'value': 'left'},
      {'icon': Icons.format_align_center, 'value': 'center'},
      {'icon': Icons.format_align_right, 'value': 'right'},
      {'icon': Icons.format_align_justify, 'value': 'justify'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Text Align',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: aligns.map((align) => ButtonSegment(
            value: align['value'] as String,
            icon: Icon(align['icon'] as IconData, size: 18),
          )).toList(),
          selected: {_propertyValues['textAlign'] ?? 'left'},
          onSelectionChanged: (value) {
            _updateProperty('textAlign', 'string', value.first);
          },
        ),
      ],
    );
  }

  Widget _buildConstraintControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNumberInput('Min Width', 'minWidth'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberInput('Max Width', 'maxWidth'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNumberInput('Min Height', 'minHeight'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberInput('Max Height', 'maxHeight'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransformControls() {
    return Column(
      children: [
        _buildNumberInput('Rotation (degrees)', 'rotation'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNumberInput('Scale X', 'scaleX'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberInput('Scale Y', 'scaleY'),
            ),
          ],
        ),
      ],
    );
  }

  void _showColorPicker(String propertyName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _propertyValues[propertyName] ?? Colors.blue,
            onColorChanged: (color) {
              setState(() {
                _propertyValues[propertyName] = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final color = _propertyValues[propertyName] as Color;
              final colorString = '#${color.value.toRadixString(16).substring(2)}';
              _updateProperty(propertyName, 'color', colorString);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _updateProperty(String propertyName, String propertyType, dynamic value) {
    setState(() {
      _propertyValues[propertyName] = value;
    });
    widget.onPropertyChanged?.call(propertyName, value);
  }

  IconData _getWidgetIcon(String widgetType) {
    switch (widgetType) {
      case 'Text':
        return Icons.text_fields;
      case 'ElevatedButton':
      case 'TextButton':
        return Icons.smart_button;
      case 'Container':
        return Icons.crop_square;
      case 'Column':
        return Icons.view_agenda;
      case 'Row':
        return Icons.view_week;
      case 'Image':
        return Icons.image;
      case 'TextField':
        return Icons.input;
      case 'Icon':
        return Icons.star;
      default:
        return Icons.widgets;
    }
  }

  IconData _getAlignmentIcon(String alignment) {
    switch (alignment) {
      case 'start':
        return Icons.vertical_align_top;
      case 'center':
        return Icons.vertical_align_center;
      case 'end':
        return Icons.vertical_align_bottom;
      case 'spaceBetween':
        return Icons.space_bar;
      case 'spaceAround':
        return Icons.horizontal_distribute;
      case 'spaceEvenly':
        return Icons.view_stream;
      // case 'stretch':
      //   return Icons.stretch;
      default:
        return Icons.align_horizontal_left;
    }
  }

  bool _hasColorProperty() {
    return ['Container', 'Text', 'Card', 'ElevatedButton'].contains(widget.widget!.widgetType);
  }

  bool _hasBorderProperty() {
    return ['Container', 'Card', 'TextField'].contains(widget.widget!.widgetType);
  }

  bool _hasShadowProperty() {
    return ['Container', 'Card', 'ElevatedButton'].contains(widget.widget!.widgetType);
  }

  bool _hasTypographyProperty() {
    return ['Text', 'ElevatedButton', 'TextButton'].contains(widget.widget!.widgetType);
  }

  bool _hasConstraintsProperty() {
    return ['Container', 'Image', 'Card'].contains(widget.widget!.widgetType);
  }

  bool _hasTransformProperty() {
    return ['Container', 'Image', 'Text'].contains(widget.widget!.widgetType);
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _tabController.dispose();
    super.dispose();
  }
}