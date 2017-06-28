class Util:
    @staticmethod
    def __spacing(sentence: str, pos_result: list):

        """ __spacing(sentence, pos_result)
        insert space_tuple (" ", "Space") into pos_result to preserver space character

        :param sentence: origin sentence (before pos analysis)
        :param pos_result: pos analysis result with self.pos(***)
        """

        sentence_index = 0
        tuple_index = 0

        for text, pos in pos_result:
            sentence_index += len(text)
            tuple_index += 1
            if len(sentence) > sentence_index and sentence[sentence_index] == " ":
                pos_result.insert(tuple_index, (" ", "Space"))

        return pos_result
