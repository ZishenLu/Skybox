using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireflyComponent : MonoBehaviour
{
    [ColorUsage(true, true)]
    public Color color = Color.white;

    [SerializeField]
    private ParticleSystem _Particle;

    // Start is called before the first frame update
    private void Start()
    {
    }

    // Update is called once per frame
    private void Update()
    {
    }
}