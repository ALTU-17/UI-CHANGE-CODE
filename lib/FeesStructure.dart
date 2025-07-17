
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


// fees_structure_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class FeesStructureApi {
  final String baseUrl;
  final String token;

  FeesStructureApi({
    required this.baseUrl,
    required this.token,
  });

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// 1) Get children of logged-in parent
  Future<List<ChildInfo>> getStudentCategoryOfParent() async {
    final url = Uri.parse('${baseUrl}get_student_category_of_parent');

    print('get_student_category_of_parent → $url');

    final res = await http.get(url, headers: _headers);
    print('Response: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load students (${res.statusCode})');
    }

    final decoded = json.decode(res.body) as Map<String, dynamic>;
    if (decoded['status'] != true) {
      throw Exception(decoded['message'] ?? 'Failed to load students');
    }

    final list = decoded['data'] as List? ?? [];
    return list
        .map((e) => ChildInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 2) Get fee structure for a child
  Future<FeesStructureData> getFeesStructure({
    required int feesCategoryId,
    required int installment,
    required String isNew,
  }) async {
    final uri = Uri.parse('${baseUrl}get_fees_structure').replace(
      queryParameters: {
        'fees_category_id': feesCategoryId.toString(),
        'installment': installment.toString(),
        'isNew': isNew,
      },
    );

    print('get_fees_structure → $uri');

    final res = await http.get(uri, headers: _headers);
    print('Response: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load fee structure (${res.statusCode})');
    }

    final decoded = json.decode(res.body) as Map<String, dynamic>;
    if (decoded['status'] != true) {
      throw Exception(decoded['message'] ?? 'Failed to load fee structure');
    }

    return FeesStructureData.fromJson(
      decoded['data'] as Map<String, dynamic>,
    );
  }
}
// fees_structure_models.dart

class ChildInfo {
  final int? feesCategoryId;
  final String firstName;
  final String className;
  final String sectionName;
  final String isNew;
  final int noOfInstallments;
  final String? message; // ✅ NEW — server message when not allotted

  ChildInfo({
    required this.feesCategoryId,
    required this.firstName,
    required this.className,
    required this.sectionName,
    required this.isNew,
    required this.noOfInstallments,
    this.message,
  });

  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    final rawCat = json['fees_category_id'];
    final rawInst = json['no_of_installments'];

    return ChildInfo(
      feesCategoryId: rawCat == null || rawCat.toString().trim().isEmpty
          ? null
          : int.tryParse(rawCat.toString()),
      firstName: json['first_name']?.toString() ?? '',
      className: json['classname']?.toString() ?? '',
      sectionName: json['sectionname']?.toString() ?? '',
      isNew: json['isNew']?.toString() ?? '',
      noOfInstallments:
      rawInst == null || rawInst.toString().trim().isEmpty
          ? 0
          : int.tryParse(rawInst.toString()) ?? 0,
      message: json['message']?.toString(),
    );
  }

  String get displayClass => '$className-$sectionName';

  /// ✅ Fees allotted only when both category and installments exist
  bool get isFeesAllotted =>
      feesCategoryId != null && noOfInstallments > 0;

  /// ✅ Message to show when not allotted (fallback if server didn't send one)
  String get notAllottedMessage =>
      (message != null && message!.trim().isNotEmpty)
          ? message!
          : 'Fee structure is not allotted';
}

class FeeItem {
  final int feeTypeId;
  final String name;
  final double amount;

  FeeItem({
    required this.feeTypeId,
    required this.name,
    required this.amount,
  });

  factory FeeItem.fromJson(Map<String, dynamic> json) {
    return FeeItem(
      feeTypeId: json['fee_type_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class FeesStructureData {
  final int feeAllotmentId;
  final String installment;
  final String academicYr;
  final String dueDate;
  final double totalInstallmentAmount;
  final List<FeeItem> feeTypes;

  FeesStructureData({
    required this.feeAllotmentId,
    required this.installment,
    required this.academicYr,
    required this.dueDate,
    required this.totalInstallmentAmount,
    required this.feeTypes,
  });

  factory FeesStructureData.fromJson(Map<String, dynamic> json) {
    return FeesStructureData(
      feeAllotmentId: json['fee_allotment_id'] ?? 0,
      installment: json['installment']?.toString() ?? '',
      academicYr: json['academic_yr']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      totalInstallmentAmount:
      double.tryParse(json['total_installment_amount']?.toString() ?? '0') ??
          0.0,
      feeTypes: (json['fee_types'] as List? ?? [])
          .map((e) => FeeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}



// fees_structure_screen.dart


class FeesStructureScreen extends StatefulWidget {
  final String apiBaseUrl;
  final String token;

  const FeesStructureScreen({
    super.key,
    required this.apiBaseUrl,
    required this.token,
  });

  @override
  State<FeesStructureScreen> createState() => _FeesStructureScreenState();
}

class _FeesStructureScreenState extends State<FeesStructureScreen>
    with TickerProviderStateMixin {
  late final FeesStructureApi _api;

  TabController? _childTabController;

  bool _isLoadingChildren = true;
  String? _childrenError;
  List<ChildInfo> _children = [];

  @override
  void initState() {
    super.initState();
    _api = FeesStructureApi(
      baseUrl: widget.apiBaseUrl,
      token: widget.token,
    );
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoadingChildren = true;
      _childrenError = null;
    });

    try {
      final children = await _api.getStudentCategoryOfParent();
      if (!mounted) return;

      _childTabController?.dispose();
      _childTabController = TabController(
        length: children.isEmpty ? 1 : children.length,
        vsync: this,
      );

      setState(() {
        _children = children;
        _isLoadingChildren = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _childrenError = e.toString();
        _isLoadingChildren = false;
      });
    }
  }

  @override
  void dispose() {
    _childTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink, Colors.blue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
                Icons.arrow_back_rounded, color: Colors.white, size: 24.w),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Fees Structure',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingChildren) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_childrenError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 48.w),
              SizedBox(height: 12.h),
              Text(
                _childrenError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _loadChildren,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_children.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, color: Colors.white70, size: 48.w),
            SizedBox(height: 12.h),
            Text(
              'No students found',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    // decide layout based on number of children
    final int count = _children.length;
    final bool scrollable = count > 2;

    return Column(
      children: [
        // Sibling Tabs
        Container(
          margin: EdgeInsets.symmetric(horizontal: 14.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TabBar(
            controller: _childTabController,
            isScrollable: scrollable,
            tabAlignment:
            scrollable ? TabAlignment.start : TabAlignment.fill,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicator: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(10.r),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.zero,
            dividerColor: Colors.transparent,
            labelPadding: EdgeInsets.zero,
            tabs: _children.map((c) {
              final tab = Tab(
                height: 52.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.firstName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        c.displayClass,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              // 3+ kids → fixed width for scrollable; 1-2 kids → full width (fill)
              return scrollable ? SizedBox(width: 110.w, child: tab) : tab;
            }).toList(),
          ),
        ),

        // Body
        Expanded(
          child: TabBarView(
            controller: _childTabController,
            children: _children
                .map((c) => _ChildFeesView(api: _api, child: c))
                .toList(),
          ),
        ),
      ],
    );
  }
}
class _ChildFeesView extends StatefulWidget {
  final FeesStructureApi api;
  final ChildInfo child;

  const _ChildFeesView({required this.api, required this.child});

  @override
  State<_ChildFeesView> createState() => _ChildFeesViewState();
}

class _ChildFeesViewState extends State<_ChildFeesView> {
  List<int> get _installmentOptions =>
      List<int>.generate(widget.child.noOfInstallments, (i) => i + 1);

  int? _selectedInstallment;
  bool _isLoading = false;
  FeesStructureData? _data;
  String? _errorMessage; // ✅ for showing "Fee structure is not alloted"

  @override
  void initState() {
    super.initState();
    if (widget.child.noOfInstallments > 0) {
      _selectedInstallment = 1;
    }
  }

  Future<void> _loadFees() async {
    if (_selectedInstallment == null) {
      _showSnack('Please select an installment', false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await widget.api.getFeesStructure(
        feesCategoryId: widget.child.feesCategoryId!, // safe: only called when allotted
        installment: _selectedInstallment!,
        isNew: widget.child.isNew.isEmpty ? 'N' : widget.child.isNew,
      );

      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // strip "Exception: " prefix if present
        final msg = e.toString().replaceFirst('Exception: ', '');
        _errorMessage = msg;
      });
      _showSnack(_errorMessage!, false);
    }
  }

  void _showSnack(String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(ok ? Icons.check_circle : Icons.warning_amber_rounded,
              color: Colors.white, size: 20.w),
          SizedBox(width: 10.w),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Not allotted → show empty state, hide the filter card entirely
    if (!widget.child.isFeesAllotted) {
      return _buildNotAllottedState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter Card ───────────────────────
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstallmentDropdown(),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _loadFees,
                      icon: _isLoading
                          ? SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Icon(Icons.search_rounded, size: 18.w),
                      label: Text(_isLoading ? 'Loading...' : 'Browse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // ── Error card (e.g. "Fee structure is not alloted to student") ──
          if (_errorMessage != null && !_isLoading) _buildErrorCard(),

          // ── Fee Table ─────────────────────────
          if (_data != null) _buildFeesTable(_data!),

          if (_data != null) SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ✅ Empty state when fees not allotted at all
  Widget _buildNotAllottedState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: Colors.white,
                size: 48.w,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              widget.child.notAllottedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.sp,
                height: 1.4,
              ),
            ),
            // SizedBox(height: 8.h),
            // Text(
            //   // ✅ Dynamic message from API (falls back if null)
            //   '${widget.child.notAllottedMessage} for ${widget.child.firstName}.\nPlease contact the school office for more details.',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: Colors.white70,
            //     fontSize: 13.sp,
            //     height: 1.4,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ✅ Inline error card when API returns a message
  Widget _buildErrorCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Icon(Icons.info_outline_rounded,
                color: Colors.orange.shade700, size: 40.w),
            SizedBox(height: 12.h),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentDropdown() {
    final options = _installmentOptions;
    final hasOptions = options.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Select Installments',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: hasOptions ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<int>(
            value: _selectedInstallment,
            isExpanded: true,
            hint: Text(
              hasOptions ? 'Select' : 'No installments available',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              isDense: true,
            ),
            items: options
                .map((e) => DropdownMenuItem<int>(
              value: e,
              child: Text(
                'Installment no.$e',
                style: TextStyle(fontSize: 13.sp),
              ),
            ))
                .toList(),
            onChanged: hasOptions
                ? (v) => setState(() => _selectedInstallment = v)
                : null,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  // ... _buildFeesTable stays the same as before
  Widget _buildFeesTable(FeesStructureData data) {
    // (unchanged)
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 16.w, color: Colors.red.shade700),
                SizedBox(width: 6.w),
                Text(
                  'Due Date',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    data.dueDate,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  Container(
                    color: Colors.grey.shade100,
                    padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Fee Type',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Amount (₹)',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...data.feeTypes.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Container(
                      color: idx.isEven ? Colors.white : Colors.grey.shade50,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.amount.toStringAsFixed(2),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: item.amount > 0
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹ ${data.totalInstallmentAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

