## Recognition
- Find objects, people, text, scenese in images and videos using ML
- Facial analyssis and facial search to do user verification, people counting
- Create a database of familiar faces or compare against celebrities

### Content Moderation
- Can also be used for content moderation, detecting inappropriate or offensive content
- You can set a Minimum Confidence Threshold for items to be flagged
- Flag sensitive content can be manually reviewed in Amazon Augmented AI (A2I)


## Transcribe
- Automatically convert speech to text
- Uses a deep leraning process called automatic speech recognition (ASR)
- You can automatically remove PII using Redaction
- Supports Automatic Language Identification for multi-lingual audio


## Polly
- Turn text into lifelike speech using deep learning
- Customize the pronunciation of words with Pronunciation lexicons
	- Stylized words: St3ph4ne -> Stephan
	- Acronyms: AWS -> Amazon Web Services
- Upload the lexicons and use them in the SynthesizeSpeech operation
- You can generate speech from plain text or from documents marked up with Speech Synthesis Markup Language (SSML), this enables more customization:
	- emphasize specific words or phrases
	- using phonetic pronunciation
	- including breathing sounds, whispering
	- using the Newscaster speaking style


## Translate
- Natuaral and accurate language translation
- Amazon Translate allows you to localize content, such as websites and applications, for internation users, and to easy translate large volumes of text


## Lex + Connect
- **Lex**: (same technology that powers Alexa)
	- Automatic Speech Recognition to convert speech to text
	- Natural Language Understanding to recognize the intent of text, callers
	- Help build chatbots, call center bots
- **Connect**:
	- Receive calls, create contact flows, cloud-based virtual contact center
	- Can integrate with other CRM systems or AWS
	- No upfront payments, 80% cheaper than traditional contact center solutions


## Comprehend
- Used for **Natural Language Processing** (NLP)
- Fully managed and serverless service
- Uses machine learning to find insights and relationships in text
	- Language of the text
	- Extracts key phrases, places, people, brands or events
	- Understands how positive or negative the text is
	- Analyzes text using tokenization and parts of speech
	- Automatically organizes a collection of text files by topic


## Comprehend Medical
- Detects and returns useful information in unstructured clinical text:
	- Physician's notes
	- Discharge summaries
	- Test results
	- Case notes
- Uses NLP to detect Protected Health Information (PHI)
- Example: Store your documents in S3, analyre real-time data with Kinesis Data Firehose, or use Transcribe to transcribe patient narratives into text that can be analyzed by Comprehend Medical


## SageMaker
- Fully managed service for developers/data scientists to build ML models
- Typically difficult to do all the processes in one place and provision servers


## Forecast
- Deliver highly accurate forecasts
- Example: predic the future sales of a raincoat
- 50% more accurate than looking at the data itself
- Reduce forecasting time from months to hours 
- It users S3 as a data source
- Use cases: Produt Demand Planning, Financial Planning, Resouce Planning, ...


## Kendra
- Fully managed document search service powered by ML
- Extract answers from within a document (text, pdf, html, PowerPoint, MS Word, FAQs, ...)
- Natural language search capabilities
- Learn from user interactions/feedback to promote preferred results (**Incremental Learning**)
- Ability to manually fine-tune search results (importance of data, freshness, custom...)


## Personalize
- Fully managed ML service to build apps with real-time personalized recommendations
- Example: personalized product recommendations/re-ranking, customized direct marketing:
	- User bought gardening tools, provide recommendations on the next one to buy
- Same technology used by amazon.com
- Integrates into existing websites, applications, SMS, email marketing systems,...
- Implement in days, not months (you don't need to build, train ad deploy)


## Textract
- Automatically extracts text, handwriting and data from any scanned documents using ML
- Extract data from forms and tables
- Read and process any type of docuyment (PDF, images, ...)
- Use cases:
	- Financial Services (e.g. invoices, financial reports)
	- Healthcare (e.g. medical records, insurance claims)
	- Public Sector (e.g. tax forms, ID documents, passports)

