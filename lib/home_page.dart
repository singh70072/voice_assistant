
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/colors.dart';
import 'package:voice_assistant/features_box.dart';
import 'package:voice_assistant/openai_services.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  OpenAIServices openAIServices = OpenAIServices();
  String? generatedContent;
  String? generatedImageUrl;


  @override
  void initState() {
    super.initState();
    initSpeechToText();
  }
  Future<void> initSpeechToText() async{
    await speechToText.initialize();
    setState(() {

    });
  }
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void>systemSpeak(String content)async{
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Allen'),
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle
                    ),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: AssetImage('Assets/images/virtualAssistant.png'))
                  ),
                )
              ],
            ),
            Container(
              
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Pallete.borderColor
                ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  topLeft: Radius.zero
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child:Text(generatedContent == null ?'Good Morning, what task can I do for you?':generatedContent!,
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor, fontSize: generatedContent == null? 25: 18),),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 10, left: 22),
              child: const Text('Here are a few features',
                style: TextStyle(fontFamily: 'Cera Pro', fontSize: 20, fontWeight: FontWeight.bold, color: Pallete.mainFontColor),),
            ),
            //Features list
            const Column(
              children: [
                FeatureBox(
                  color: Pallete.firstSuggestionBoxColor,
                  headerText: 'ChatGPT',
                  discriptionText: 'a smarter way to stay organised and informed with ChatGPT',
                ),
                FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: 'Dalle-E',
                    discriptionText:'Get inspired and stay creative with your personal assistant powered by Dall-E'
                ),
                FeatureBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerText: 'Smart Voice Assistant',
                    discriptionText: 'Get the best of both world with the voice assistant powered by Dall-E and ChatGPT'
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: ()async{
          if(await speechToText.hasPermission && speechToText.isNotListening){
           await startListening();
          }
          else if(speechToText.isListening){
            final speech =  await openAIServices.isArtPromptAPI(lastWords);
            if(speech.contains('https')){
              generatedImageUrl = speech;
              generatedContent = null;
              setState(() {

              });
            }else{
              generatedImageUrl = null;
              generatedContent = speech;
              setState(() async {
                await systemSpeak(speech);
              });
            }

            await stopListening();
          }
          else{
            initSpeechToText();
          }
        },
        child: const Icon(Icons.mic),
      ),


    );
  }
}
