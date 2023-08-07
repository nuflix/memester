
import "dart:convert";
import "dart:io";
import "package:dart_amqp/dart_amqp.dart";
import "package:untitled/model/models/admin_response.dart";

class Networker {

  static final Networker _instance = Networker._internal();

// using a factory is important
// because it promises to return _an_ object of this type
// but it doesn't promise to make a new one.
  factory Networker() {
    return _instance;
  }

// This named constructor is the "real" constructor
// It'll be called exactly once, by the static property assignment above
// it's also private, so it can only be called in this class
  Networker._internal() {
// initialization logic
  }

  void fetch() async {

      ConnectionSettings settings = ConnectionSettings(
          host: '4.tcp.ngrok.io',
          authProvider: const PlainAuthenticator("admin", "admin"),
          virtualHost: 'app',
          port: 15608
      );

      Client client = new Client(settings: settings);

      ProcessSignal.sigint.watch().listen((_) {
        client.close().then((_) {
          print("close client");
          exit(0);
        });
      });


      client
          .channel()
          .then((Channel channel) {
        return channel.exchange("logs", ExchangeType.FANOUT, durable: false);
      })
          .then((Exchange exchange) {
        print(" [*] Waiting for messages in logs. To Exit press CTRL+C");
        return exchange.bindPrivateQueueConsumer(null);
      })
          .then((Consumer consumer) {
        consumer.listen((AmqpMessage event) {
          AdminResponse adminResponse = AdminResponse();
          adminResponse.pushData(json.decode(event.payloadAsString));

          //print(" [x] Received ${event.payloadAsString}");
        });
      });
    }


}