import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
//import 'consumable_store.dart';

const bool kAutoConsume = true;

class RemoveAds {
  static String removeAdsProdID = 'sudoku_free_remove_ads';
  final List<String> _kProductIds = <String>[
    removeAdsProdID,
  ];

  final InAppPurchaseConnection connection;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  RemoveAds(this.connection) {
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;

    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });

    initStoreInfo();
  }

  Future<ProductDetailsResponse> get productDetailResponse async =>
      await connection.queryProductDetails(_kProductIds.toSet());

  Future<void> initStoreInfo() async {
    final bool isAvailable = await connection.isAvailable();

    if (!isAvailable) {
      _isAvailable = isAvailable;
      _products = [];
      _purchases = [];
      _notFoundIds = [];
      _purchasePending = false;
      _loading = false;
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await connection.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      _queryProductError = productDetailResponse.error.message;
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = [];
      _notFoundIds = productDetailResponse.notFoundIDs;
      _purchasePending = false;
      _loading = false;
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      _queryProductError = null;
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = [];
      _notFoundIds = productDetailResponse.notFoundIDs;
      _purchasePending = false;
      _loading = false;
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
        await connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      // handle query past purchase error..
    }

    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (await _verifyPurchase(purchase)) {
        verifiedPurchases.add(purchase);
      }
    }

    _isAvailable = isAvailable;
    _products = productDetailResponse.productDetails;
    _purchases = verifiedPurchases;
    _notFoundIds = productDetailResponse.notFoundIDs;
    _purchasePending = false;
    _loading = false;
  }

  dispose() {
    _subscription.cancel();
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify a purchase purchase details before delivering the product.
    if (purchaseDetails.productID == removeAdsProdID) {
      _purchases.add(purchaseDetails);
      _purchasePending = false;
    }
  }

  void handleError(IAPError error) {
    _purchasePending = false;
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == removeAdsProdID) {
            await InAppPurchaseConnection.instance
                .completePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }

  Map<String, PurchaseDetails> get purchases =>
      Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
        if (purchase.pendingCompletePurchase) {
          InAppPurchaseConnection.instance.completePurchase(purchase);
        }
        return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
      }));

  List<ProductDetails> get productList => _products;
  bool get isInstanceAvailable => _isAvailable;
}
