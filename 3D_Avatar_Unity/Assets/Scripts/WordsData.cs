using UnityEngine;

[CreateAssetMenu(fileName = "WordData", menuName = "WordData/Words")]
public class WordsData : ScriptableObject
{
    public string[] words;

    public int GetWordID(string word)
    {
        int i = 0;
        foreach (var item in words)
        {
            if (item.ToLower() == word.ToLower())
                return i;
            i++;
        }
        return -1;
    }
}
