import 'package:LaCoro/presentation/core/bloc/base_bloc.dart';
import 'package:LaCoro/presentation/core/ui/app_colors.dart';
import 'package:LaCoro/presentation/core/ui/custom_widgets/cart_total_bottom.dart';
import 'package:LaCoro/presentation/core/ui/custom_widgets/product_item.dart';
import 'package:LaCoro/presentation/store_details/store_details_bloc.dart';
import 'package:domain/entities/item_entity.dart';
import 'package:domain/entities/store_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';

class StoreDetailsPage extends StatefulWidget {
  static const STORE_DETAILS_ROUTE = '/store_details';

  @override
  _StoreDetailsPageState createState() => _StoreDetailsPageState(StoreDetailsBloc(Injector.getInjector().get()));
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  final StoreDetailsBloc _bloc;

  _StoreDetailsPageState(this._bloc);

  @override
  Widget build(BuildContext context) {
    final StoreEntity store = ModalRoute.of(context).settings.arguments;
    _bloc.store = store;

    Map<ItemEntity, List<ItemEntity>> itemList;
    int orderQuantity = 0;
    double cartTotal = 0;
    return Scaffold(
        appBar: AppBar(title: Text(store.name)),
        body: SafeArea(
          child: BlocBuilder(
              bloc: _bloc,
              builder: (context, state) {
                // Handle states
                if (state is InitialState) _bloc.add(GetSortedItemsEvent());
                if (state is ErrorState) {
                  // todo show snack with error;
                }
                if (state is LoadingState) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state is SuccessState<Map<ItemEntity, List<ItemEntity>>>) {
                  itemList = state.data;
                }

                if (state is OrderChangedSate) {
                  orderQuantity = state.quantity;
                  cartTotal = state.cartTotal;
                }

                // Build widget
                return Column(
                  children: <Widget>[
                    Expanded(flex: 1, child: Text(store.name)),
                    Center(child: Text(store.searchTags.join('-'))),
                    Expanded(flex: 5, child: buildItemList(itemList) ?? Center(/*todo agregar mensaje cuando no hay productos */)),
                    CartTotalBottom(orderQuantity, "\$$cartTotal"),
                  ],
                );
              }),
        ));
  }

  Widget buildItemList(Map<ItemEntity, List<ItemEntity>> items) {
    return items == null
        ? Center(child: CircularProgressIndicator())
        : ListView.separated(
            shrinkWrap: true, //Added
            separatorBuilder: (BuildContext context, int index) => Divider(
                  thickness: 10,
                  height: 50,
                  color: AppColors.greyLight,
                ),
            itemCount: items?.length ?? 0,
            itemBuilder: (c, i) {
              final category = items.keys.elementAt(i);
              return Wrap(children: [
                Padding(padding: const EdgeInsets.all(16.0), child: Text(category.name, style: Theme.of(context).textTheme.headline4)),
                Wrap(
                    children: items[category]
                        .map((e) => ProductItem(
                              itemEntity: e,
                              onQuantityChange: (value) => _bloc.add(UpdateProductEvent(e, value)),
                            ))
                        .toList())
              ]);
            });
  }
}
