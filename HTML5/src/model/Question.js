var Type = {};

(function () {
    /**
     * enum for Question Type
     * @type {{UnknownType: number, LogoType: number, TimedObfuscatorType: number, TextualType: number, description: {0: string, 1: string, 2: string, 3: string}}}
     */
    Type.QuestionType = {
        UnknownType: 0,
        LogoType: 1,
        TimedObfuscatorType: 2,
        TextualType: 3,

        /**
         * example:
         * var type = QuestionType.LogoType
         * var desc = QuestionType.description[type] /// "Logo Type"
         */
        description: {
            0: "Unknown type",
            1: "Logo type",
            2: "Timed Obfuscator type",
            3: "Textual type"
        }
    };

    /**
     * enum for Question Category
     * @type {{UnknownCategory: number, LogoToNameCategory: number, LogoToTickerSymbolCategory: number, NameToPriceRangeCategory: number, NameToMarketCapRangeCategory: number, PriceRangeToCompanyNameCategory: number, HighestMarketCapCategory: number, LowestMarketCapCategory: number, CompanyNameToExchangeSymbolCategory: number, OddOneOutCategory: number, CompanyNameToSectorCategory: number, StaticCategory: number, description: {0: string, 1: string, 2: string, 3: string, 4: string, 5: string, 6: string, 7: string, 8: string, 9: string, 10: string, 11: string}}}
     */
    Type.QuestionCategory = {
        UnknownCategory: 0,
        LogoToNameCategory: 1,
        LogoToTickerSymbolCategory: 2,
        NameToPriceRangeCategory: 3,
        NameToMarketCapRangeCategory: 4,
        PriceRangeToCompanyNameCategory: 5,
        HighestMarketCapCategory: 6,
        LowestMarketCapCategory: 7,
        CompanyNameToExchangeSymbolCategory: 8,
        OddOneOutCategory: 9,
        CompanyNameToSectorCategory: 10,
        StaticCategory: 11,

        /**
         * example:
         * var cate = QuestionCategory.LogoToNameCategory
         * var desc = QuestionCategory.description[cate] /// "[1] Logo -> Name"
         */
        description: {
            0: "Unknown category",
            1: "[1] Logo -> Name",
            2: "[2] Logo -> Ticker Symbol",
            3: "[3] Name -> Price Range",
            4: "[4] Name -> Market Cap Range",
            5: "[5] Price Range -> Company name",
            6: "[6] Highest Market Cap",
            7: "[7] Lowest Market Cap",
            8: "[8] Company name -> Exchange symbol",
            9: "[9] Odd one out",
            10: "[10] Company Name -> Sector",
            11: "[11] Static questions"
        }
    };
}() );

(function () {
    /**
     * Convert json of question to object
     * @param questionDTO
     * @constructor
     */
    PopQuiz.Question = function Question(questionDTO) {
        /**
         *
         * @type {number}
         */
        this.questionId = questionDTO["id"];
        /**
         *
         * @type {QuestionCategory}
         */
        this.questionCategory = questionDTO["category"];
        /**
         *
         * @type {string}
         */
        this.accesoryImageContent = "";
        /**
         *
         * @type {number}
         */
        this.questionType = Type.QuestionType.UnknownType;
        /**
         *
         * @type {string}
         */
        this.questionContent = "";
        /**
         *
         * @type {string}
         */
        this.questionImageURLString = "";

        var option1 = new PopQuiz.Option(questionDTO["option1"]);
        var option2 = new PopQuiz.Option(questionDTO["option2"]);
        var option3 = new PopQuiz.Option(questionDTO["option3"]);
        var option4 = new PopQuiz.Option(questionDTO["option4"]);
        /**
         *
         * @type {PopQuiz.OptionSet}
         */
        this.options = new PopQuiz.OptionSet(option1, [option2, option3, option4]);
        /**
         *
         * @returns {boolean}
         */
        this.isGraphical = function () {
            return (this.questionType === Type.QuestionType.LogoType ||
            this.questionType === Type.QuestionType.TimedObfuscatorType)
        };

        var content = questionDTO["content"];
        var split = content.split("|");
        var mainContent = "";
        if (split.length === 2) {
            mainContent = split[0];
            this.accesoryImageContent = split[1];
        } else {
            mainContent = split;
        }

        switch (this.questionCategory) {
            case 1:
                this.questionType = Type.QuestionType.LogoType;
                this.questionCategory = Type.QuestionCategory.LogoToNameCategory;
                this.questionContent = "Which of the following companies does this logo correspond to?";
                this.questionImageURLString = mainContent;
                break;

            case 2:
                this.questionType = Type.QuestionType.LogoType;
                this.questionCategory = Type.QuestionCategory.LogoToTickerSymbolCategory;
                this.questionContent = "Which of the following ticker symbols does this logo correspond to?";
                this.questionImageURLString = mainContent;
                break;

            case 3:
                this.questionType = Type.QuestionType.TextualType;
                this.questionCategory = Type.QuestionCategory.NameToPriceRangeCategory;
                this.questionContent = "In which of the price ranges did " + mainContent + "recently trade?";
                break;

            case 4:
                this.questionType = Type.QuestionType.TextualType;
                this.questionCategory = Type.QuestionCategory.NameToMarketCapRangeCategory;
                this.questionContent = "Which of the following ranges best represents the market cap of " + mainContent;
                break;

            case 5:
                this.questionType = Type.QuestionType.TextualType;
                this.questionCategory = Type.QuestionCategory.PriceRangeToCompanyNameCategory;
                this.questionContent = "Which of the 4 companies below trades in the price range of " + mainContent;
                break;

            case 6:
                this.questionType = Type.QuestionType.TextualType;
                this.questionCategory = Type.QuestionCategory.HighestMarketCapCategory;
                this.questionContent = "Which of the following companies has highest market cap?";
                break;

            case 7:
                this.questionType = Type.QuestionType.TextualType;
                this.questionCategory = Type.QuestionCategory.LowestMarketCapCategory;
                this.questionContent = "Which of the following companies has lowest market cap?";
                break;

            case 8:
                this.questionType = Type.QuestionType.TextualType;
                this.questionCategory = Type.QuestionCategory.CompanyNameToExchangeSymbolCategory;
                this.questionContent = "Identify the exchange symbol of " + mainContent;
                break;

            case 9:
                this.questionType = Type.QuestionType.TextualType;
                this.questionCategory = Type.QuestionCategory.OddOneOutCategory;
                this.questionContent = "Spot the odd one from the four companies below.";
                break;

            case 10:
                this.questionType = Type.QuestionType.TextualType;
                this.questionCategory = Type.QuestionCategory.CompanyNameToSectorCategory;
                this.questionContent = "In which sector does the " + mainContent + " operate?";
                break;

            case 11:
                this.questionType = Type.QuestionType.TextualType;
                this.questionCategory = Type.QuestionCategory.StaticCategory;
                this.questionContent = mainContent + " ";
                break;

            default:
                this.questionType = Type.QuestionType.UnknownType;
                this.questionContent = content + " ";
        }
    };
}() );