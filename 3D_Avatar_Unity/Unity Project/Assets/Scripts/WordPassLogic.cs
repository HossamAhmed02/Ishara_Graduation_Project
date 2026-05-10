using UnityEngine;

public class WordPassLogic : MonoBehaviour
{
    private WordPlayer player;

   


    void Awake()
    {
        player = FindAnyObjectByType<WordPlayer>();
    }
   
    public void ProcessSentence(string sentence)
    {
        if (player == null)
        {
            Debug.LogError("WordPlayer not found!");
            return;
        }

        if (string.IsNullOrEmpty(sentence))
        {
            Debug.LogWarning("Empty sentence!");
            return;
        }

        string cleaned = sentence.Trim().ToUpper();

        string[] words = cleaned.Split(
            new char[] { ' ', '\n', '\t' },
            System.StringSplitOptions.RemoveEmptyEntries
        );

        Debug.Log("Processed words: " + string.Join(", ", words));

        player.AddToQueue(words);
        player.PlayWordList();
    }
    public void ReceiveGloss(string message)
    {
        Debug.Log("From Flutter: " + message);

        GlossData data = JsonUtility.FromJson<GlossData>(message);

        if (data != null && !string.IsNullOrEmpty(data.gloss))
        {
            ProcessSentence(data.gloss);
        }
        else
        {
            Debug.LogWarning("Invalid JSON!");
        }
    }
    [System.Serializable]
    public class GlossData
    {
        public string gloss;
    }
}
