import 'package:doantn/data/provider/address_provider.dart';
import 'package:doantn/screens/add_address_screen.dart';
import 'package:doantn/screens/edit_address_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text("Địa chỉ nhận hàng"),
        actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAddressScreen(),
                      ));
                },
                icon: const Icon(Icons.add_location_alt))
          ],
      ),
      body: Column(
        children: [
        Expanded(
            child: Consumer<AddressProvider>(builder: (context, provider, child) {
              provider.loadAddresses();
              return FutureBuilder(
                future: provider.getAddresses(),
                builder: (context, snapshot) {
                  if(snapshot.hasError){
                    return const Center(
                        child: Column(mainAxisSize: MainAxisSize.min,children: [
                          Text("Có lỗi xảy ra!", style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 120,),
                        ]));
                  } else if(!snapshot.hasData || snapshot.data!.isEmpty){
                      return const Center(
                          child: Column(mainAxisSize: MainAxisSize.min,children: [
                            Image(
                              image: AssetImage('assets/images/no_gps.png'),
                              width: 130,
                              height: 130,
                            ),
                            SizedBox(height: 12,),
                            Text("Chưa có địa chỉ nào!", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text("Hãy thêm địa chỉ nhận hàng"),
                            SizedBox(height: 120,),
                          ]));
                    }else {
                      //logger.w(provider.addresses.length);
                      return ListView.builder(
                        itemCount: provider.addresses.length,
                        itemBuilder: (context, index) {
                          final address = provider.addresses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                            child: Dismissible(
                              key: Key('$index'),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction){
                                provider.removeAddress(index);
                              },
                              confirmDismiss: (direction) async {
                                bool shouldDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: const Text('Sau khi xóa sẽ không thể hoàn tác'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(false); // Không xóa
                                          },
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(true); // Xóa
                                          },
                                          child: const Text('Xóa'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return shouldDelete;
                              },
                              background: Container(
                                color: Colors.red, // Màu nền khi vuốt
                                alignment: Alignment.centerRight,
                                child: const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(Icons.delete,
                                        color: Colors.white)),
                              ),
                              child: ListTile(
                                title: Text(address.name, style: const TextStyle(fontWeight: FontWeight.bold),),
                                subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(address.phone, style: const TextStyle(fontSize: 12)),
                                      Text(address.address, style: const TextStyle(fontSize: 12),),
                                    ]),
                                leading: Checkbox(
                                  activeColor: Colors.amber,
                                  value: address.isChecked,
                                  onChanged: (bool? value) {
                                    if (value == true) {
                                      provider.updateCheckedStatus(index);
                                    }
                                  },
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const EditAddressScreen(),
                                              settings: RouteSettings(
                                                  arguments: index)));
                                    },
                                    icon: const Icon(Icons.edit_rounded)),
                              ),
                            ),
                          );
                        },
                      );
                  }
                },
              );
            },)
        )
      ],)
    );
  }
}
