// lib/presentation/builder/property_editor.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../providers/builder_provider.dart';
import '../../core/constants/app_colors.dart';

class PropertyEditor extends StatefulWidget {
  final dynamic widget;
  final Function(String, dynamic)? onPropertyChanged;

  const PropertyEditor({
    super.key,
    required this.widget,
    this.onPropertyChanged,
  });

  @override
  State<PropertyEditor> createState() => _PropertyEditorState();
}

class _PropertyEditorState extends State<PropertyEditor> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _propertyValues = {};

  @override
  void initState() {
    super.initState();
    _initializeProperties();
  }

  void _initializeProperties() {
    // Initialize controllers and values for widget properties
    if (widget.widget?.properties != null) {
      for (var property in widget.widget.properties) {
        final key = property.propertyName;
        _propertyValues[key] = property.value;

        if (property.propertyType == 'string' ||
            property.propertyType == 'integer' ||
            property.propertyType == 'decimal' ||
            property.propertyType == 'url') {
          _controllers[key] = TextEditingController(
            text: property.value?.toString() ?? '',
          );
        }
      }
    }
  }

  @override
  void didUpdateWidget(PropertyEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.widget != widget.widget) {
      _clearControllers();
      _initializeProperties();
    }
  }

  void _clearControllers() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _propertyValues.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.widget == null) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getWidgetIcon(widget.widget.widgetType),
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.widget.widgetType,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.widget.widgetId != null)
                          Text(
                            'ID: ${widget.widget.widgetId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      context.read<BuilderProvider>().selectWidget(null);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Properties
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Widget ID
              _buildTextField(
                'Widget ID',
                'widget_id',
                widget.widget.widgetId ?? '',
                'Enter a unique identifier',
                onChanged: (value) {
                  widget.onPropertyChanged?.call('widget_id', value);
                },
              ),
              const SizedBox(height: 16),

              // Common Properties
              _buildSectionHeader('Common Properties'),
              ..._buildCommonProperties(),

              // Type-specific properties
              if (_getSpecificProperties().isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionHeader('${widget.widget.widgetType} Properties'),
                ..._getSpecificProperties(),
              ],

              // Layout Properties
              if (_hasLayoutProperties()) ...[
                const SizedBox(height: 24),
                _buildSectionHeader('Layout'),
                ..._buildLayoutProperties(),
              ],

              // Style Properties
              if (_hasStyleProperties()) ...[
                const SizedBox(height: 24),
                _buildSectionHeader('Style'),
                ..._buildStyleProperties(),
              ],

              // Actions
              if (_hasActionProperties()) ...[
                const SizedBox(height: 24),
                _buildSectionHeader('Actions'),
                ..._buildActionProperties(),
              ],
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
          Icon(
            Icons.touch_app,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Select a widget',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click on any widget in the canvas\nto edit its properties',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  List<Widget> _buildCommonProperties() {
    final properties = <Widget>[];

    switch (widget.widget.widgetType) {
      case 'Container':
        properties.addAll([
          _buildNumberField('Width', 'width', null),
          const SizedBox(height: 12),
          _buildNumberField('Height', 'height', null),
          const SizedBox(height: 12),
          _buildColorPicker('Background Color', 'backgroundColor'),
          const SizedBox(height: 12),
          _buildNumberField('Padding', 'padding', 0),
          const SizedBox(height: 12),
          _buildNumberField('Margin', 'margin', 0),
        ]);
        break;

      case 'Text':
        properties.addAll([
          _buildTextField('Text', 'text', '', 'Enter text'),
          const SizedBox(height: 12),
          _buildNumberField('Font Size', 'fontSize', 14),
          const SizedBox(height: 12),
          _buildDropdown('Font Weight', 'fontWeight', [
            'normal',
            'bold',
            'w100',
            'w200',
            'w300',
            'w400',
            'w500',
            'w600',
            'w700',
            'w800',
            'w900',
          ], 'normal'),
          const SizedBox(height: 12),
          _buildColorPicker('Text Color', 'color'),
          const SizedBox(height: 12),
          _buildDropdown('Text Align', 'textAlign', [
            'left',
            'center',
            'right',
            'justify',
          ], 'left'),
        ]);
        break;

      case 'Image':
        properties.addAll([
          _buildTextField('Image URL', 'imageUrl', '', 'Enter image URL'),
          const SizedBox(height: 12),
          _buildNumberField('Width', 'width', null),
          const SizedBox(height: 12),
          _buildNumberField('Height', 'height', null),
          const SizedBox(height: 12),
          _buildDropdown('Fit', 'fit', [
            'cover',
            'contain',
            'fill',
            'fitWidth',
            'fitHeight',
            'none',
            'scaleDown',
          ], 'cover'),
        ]);
        break;

      case 'ElevatedButton':
      case 'TextButton':
      case 'OutlinedButton':
        properties.addAll([
          _buildTextField('Button Text', 'text', '', 'Enter button text'),
          const SizedBox(height: 12),
          _buildColorPicker('Background Color', 'backgroundColor'),
          const SizedBox(height: 12),
          _buildColorPicker('Text Color', 'textColor'),
          const SizedBox(height: 12),
          _buildActionSelector('On Pressed', 'onPressed'),
        ]);
        break;

      case 'TextField':
        properties.addAll([
          _buildTextField('Label', 'labelText', '', 'Enter label'),
          const SizedBox(height: 12),
          _buildTextField('Hint', 'hintText', '', 'Enter hint text'),
          const SizedBox(height: 12),
          _buildTextField('Helper', 'helperText', '', 'Enter helper text'),
          const SizedBox(height: 12),
          _buildSwitch('Obscure Text', 'obscureText', false),
          const SizedBox(height: 12),
          _buildNumberField('Max Lines', 'maxLines', 1),
        ]);
        break;

      case 'Column':
      case 'Row':
        properties.addAll([
          _buildDropdown('Main Axis Alignment', 'mainAxisAlignment', [
            'start',
            'end',
            'center',
            'spaceBetween',
            'spaceAround',
            'spaceEvenly',
          ], 'start'),
          const SizedBox(height: 12),
          _buildDropdown('Cross Axis Alignment', 'crossAxisAlignment', [
            'start',
            'end',
            'center',
            'stretch',
            'baseline',
          ], 'center'),
          const SizedBox(height: 12),
          _buildDropdown('Main Axis Size', 'mainAxisSize', [
            'min',
            'max',
          ], 'max'),
        ]);
        break;

      case 'ListView':
        properties.addAll([
          _buildDropdown('Scroll Direction', 'scrollDirection', [
            'vertical',
            'horizontal',
          ], 'vertical'),
          const SizedBox(height: 12),
          _buildSwitch('Shrink Wrap', 'shrinkWrap', false),
          const SizedBox(height: 12),
          _buildSwitch('Primary', 'primary', true),
          const SizedBox(height: 12),
          _buildDataSourceSelector('Data Source', 'dataSource'),
        ]);
        break;

      case 'GridView':
        properties.addAll([
          _buildNumberField('Cross Axis Count', 'crossAxisCount', 2),
          const SizedBox(height: 12),
          _buildNumberField('Child Aspect Ratio', 'childAspectRatio', 1.0),
          const SizedBox(height: 12),
          _buildNumberField('Cross Axis Spacing', 'crossAxisSpacing', 0),
          const SizedBox(height: 12),
          _buildNumberField('Main Axis Spacing', 'mainAxisSpacing', 0),
          const SizedBox(height: 12),
          _buildDataSourceSelector('Data Source', 'dataSource'),
        ]);
        break;
    }

    return properties;
  }

  List<Widget> _getSpecificProperties() {
    // Return widget-specific properties
    return [];
  }

  List<Widget> _buildLayoutProperties() {
    return [
      _buildNumberField('Order', 'order', widget.widget.order ?? 0),
    ];
  }

  List<Widget> _buildStyleProperties() {
    return [];
  }

  List<Widget> _buildActionProperties() {
    return [];
  }

  Widget _buildTextField(
    String label,
    String propertyName,
    String initialValue,
    String hint, {
    Function(String)? onChanged,
  }) {
    _controllers[propertyName] ??= TextEditingController(text: initialValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[propertyName],
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: (value) {
            _propertyValues[propertyName] = value;
            onChanged?.call(value);
            _updateProperty(propertyName, 'string', value);
          },
        ),
      ],
    );
  }

  Widget _buildNumberField(
    String label,
    String propertyName,
    num? initialValue, {
    bool allowDecimal = false,
  }) {
    _controllers[propertyName] ??= TextEditingController(
      text: initialValue?.toString() ?? '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[propertyName],
          keyboardType: TextInputType.numberWithOptions(
            decimal: allowDecimal,
          ),
          inputFormatters: [
            if (allowDecimal)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: 'Enter ${allowDecimal ? "number" : "integer"}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: (value) {
            final numValue = allowDecimal
                ? double.tryParse(value)
                : int.tryParse(value);
            _propertyValues[propertyName] = numValue;
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

  Widget _buildSwitch(String label, String propertyName, bool initialValue) {
    _propertyValues[propertyName] ??= initialValue;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: _propertyValues[propertyName] ?? false,
          onChanged: (value) {
            setState(() {
              _propertyValues[propertyName] = value;
            });
            _updateProperty(propertyName, 'boolean', value);
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String propertyName,
    List<String> options,
    String initialValue,
  ) {
    _propertyValues[propertyName] ??= initialValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _propertyValues[propertyName],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _propertyValues[propertyName] = value;
            });
            _updateProperty(propertyName, 'string', value);
          },
        ),
      ],
    );
  }

  Widget _buildColorPicker(String label, String propertyName) {
    _propertyValues[propertyName] ??= Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            _showColorPicker(propertyName);
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
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _propertyValues[propertyName] is Color
                        ? _propertyValues[propertyName]
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _propertyValues[propertyName] is Color
                      ? '#${(_propertyValues[propertyName] as Color).value.toRadixString(16).substring(2).toUpperCase()}'
                      : 'Select color',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
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
                const Icon(Icons.flash_on, size: 20, color: AppColors.warning),
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

  Widget _buildDataSourceSelector(String label, String propertyName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            // TODO: Show data source selector dialog
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
                const Icon(Icons.storage, size: 20, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _propertyValues[propertyName]?.toString() ?? 'Select data source',
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
    final builderProvider = context.read<BuilderProvider>();
    builderProvider.updateWidgetProperty(
      widgetId: widget.widget.id.toString(),
      propertyName: propertyName,
      propertyType: propertyType,
      value: value,
    );
    widget.onPropertyChanged?.call(propertyName, value);
  }

  bool _hasLayoutProperties() {
    return ['Column', 'Row', 'Stack', 'Container', 'Padding', 'Center']
        .contains(widget.widget.widgetType);
  }

  bool _hasStyleProperties() {
    return ['Container', 'Card', 'Text', 'ElevatedButton', 'TextButton']
        .contains(widget.widget.widgetType);
  }

  bool _hasActionProperties() {
    return ['ElevatedButton', 'TextButton', 'IconButton', 'FloatingActionButton', 'ListTile']
        .contains(widget.widget.widgetType);
  }

  IconData _getWidgetIcon(String widgetType) {
    switch (widgetType) {
      case 'Column':
        return Icons.view_agenda;
      case 'Row':
        return Icons.view_week;
      case 'Container':
        return Icons.crop_square;
      case 'Text':
        return Icons.text_fields;
      case 'Image':
        return Icons.image;
      case 'Button':
      case 'ElevatedButton':
      case 'TextButton':
        return Icons.smart_button;
      case 'TextField':
        return Icons.input;
      case 'ListView':
        return Icons.list;
      case 'GridView':
        return Icons.grid_on;
      default:
        return Icons.widgets;
    }
  }

  @override
  void dispose() {
    _clearControllers();
    super.dispose();
  }
}