using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WordPlayer : MonoBehaviour
{
    public WordsData word_data;
    public Queue<int> word_list = new Queue<int>();

    private Animator anim;
    private bool isPlaying = false;
    private AnimatorStateInfo currentState;

    void Start()
    {
        anim = GetComponent<Animator>();
    }

    public void AddToQueue(string[] words)
    {
        foreach (var word in words)
        {
            int id = word_data.GetWordID(word);

            if (id != -1)
                word_list.Enqueue(id);
        }
    }

    void Update()
    {
        if (isPlaying && anim)
        {
            currentState = anim.GetCurrentAnimatorStateInfo(0);

            if (currentState.IsName("idle") && word_list.Count <= 0)
            {
                isPlaying = false;
            }
            else if (currentState.IsName("idle"))
            {
                int nextAnim = word_list.Peek();
                word_list.Dequeue();
                isPlaying = false;
                StartCoroutine(PlayWord(nextAnim));
            }
        }
    }

    IEnumerator PlayWord(int id)
    {
        anim.SetInteger("signID", id);

        yield return new WaitForSeconds(1);

        anim.SetInteger("signID", 0);
        isPlaying = true;
    }

    public void PlayWordList()
    {
        isPlaying = true;
    }
}
