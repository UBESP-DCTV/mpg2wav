// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

(function() {
  // <code>
  "use strict";
  
  // pull in the required packages.
  var sdk = require("microsoft-cognitiveservices-speech-sdk");
  var fs = require("fs");
  

  // replace with your own subscription key,
  // service region (e.g., "westus"), and
  // the name of the file you want to run
  // through the speech recognizer.
  var subscriptionKey = "30b19d65c6b24a4b846419418427b39f";
  var serviceRegion = "westeurope"; // e.g., "westus"
  var filename = "F://Archivio Master UBEP/Masters 2016/Biostatistica avanzata per la ricerca clinica/Modulo2_Berchialla/Week 6/BAM2W6_L2_PB.wav"; // 16000 Hz, Mono
  var tempText = '';
  
  // create the push stream we need for the speech sdk.
  var pushStream = sdk.AudioInputStream.createPushStream();
  
  // open the file and push it to the push stream.
  fs.createReadStream(filename).on('data', function(arrayBuffer) {
    pushStream.write(arrayBuffer.slice());
  }).on('end', function() {
    pushStream.close();
  });
  
  // we are done with the setup
  console.log("Now recognizing from: " + filename);
  
  // now create the audio-config pointing to our stream and
  // the speech config specifying the language.
  var audioConfig = sdk.AudioConfig.fromStreamInput(pushStream);
  var speechConfig = sdk.SpeechConfig.fromSubscription(subscriptionKey, serviceRegion);
  
  // setting the recognition language to English.
  speechConfig.speechRecognitionLanguage = "it-IT";
  
  // create the speech recognizer.
  var recognizer = new sdk.SpeechRecognizer(speechConfig, audioConfig);
  

  recognizer.startContinuousRecognitionAsync(function () {}, function (err) {
    console.trace("err - " + err);
    cstat = 100;
    //removefile(url);
    res.json({
        status: "OK",
        message: tempText
    });
  });

  recognizer.canceled = function (s, e) {
      var str = "(cancel) Reason: " + sdk.CancellationReason[e.reason];
      if (e.reason === sdk.CancellationReason.Error) {
          str += ": " + e.errorDetails;
      }

      cstat = 100;
      //removefile(url);
      res.json({
          status: "OK",
          message: tempText
      });
  }

  recognizer.recognized = function (s, e) {
      // Indicates that recognizable speech was not detected, and that recognition is done.
      if (e.result.reason === sdk.ResultReason.NoMatch) {
          var noMatchDetail = sdk.NoMatchDetails.fromResult(e.result);
          //console.log("\r\n(recognized)  Reason: " + sdk.ResultReason[e.result.reason] + " NoMatchReason: " + sdk.NoMatchReason[noMatchDetail.reason]);
          // tempText += e.result.text;
      } else {
          console.log("\r\n(recognized)  Reason: " + sdk.ResultReason[e.result.reason] + " Text: " + e.result.text);
          tempText += e.result.text;
          
          
      }
      fs.writeFileSync("F://Archivio Master UBEP/Masters 2016/Biostatistica avanzata per la ricerca clinica/Modulo2_Berchialla/Week 6/BAM2W6_L2_PB-MS_COGNITIVE_ELABORATED.txt", tempText);
      //recognizer.stopContinuousRecognitionAsync();
   };

  recognizer.recognizing = function (s, e) {
      //var str = "(recognizing) Reason: " + e.result + "---"+e.privResult;
     // console.log(e);
  };

  recognizer.sessionStopped = function (s, e) {
      recognizer.stopContinuousRecognitionAsync()
      var str = "(sessionStopped) SessionId: " + e.sessionId;
      cstat = 100;
      removefile(url);
      res.json({
          status: "OK",
          message: tempText
      });
     // console.log(str);
  };


  // recognizer.recognizeOnceAsync(
  //   function (result) {
  //     console.log(result);
  //     fs.writeFileSync('C:\\Users\\MarcoGhidina\\Music\\test.txt', result.text);
  //     recognizer.close();
  //     recognizer = undefined;
  //   },
  //   function (err) {
  //     console.trace("err - " + err);
  
  //     recognizer.close();
  //     recognizer = undefined;
  //   });
  // </code>
  
}());
  
