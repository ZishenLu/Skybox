using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class LunarComponent : IComponent
{
    public Color LunarColor = new Color32(255, 244, 214, 255);

    [Range(0.001f, 0.1f)]
    public float Intensity = 0.055f;

    [Range(1f, 20f)]
    public float Radius = 16f;

    [Range(1f, 10f)]
    public float Atten = 8f;

    [SerializeField] private Transform m_Sun;

    private void Update()
    {
        transform.localEulerAngles = new Vector3(-m_Sun.transform.localEulerAngles.x, -m_Sun.transform.localEulerAngles.y, -m_Sun.transform.localEulerAngles.z);
    }

    private void LateUpdate()
    {
        if(m_skyboxController != null)
        {
            m_skyboxController.SkyboxMat.SetFloat("_MoonRadius", Radius);
            m_skyboxController.SkyboxMat.SetFloat("_MoonIntensity", Intensity);
            m_skyboxController.SkyboxMat.SetVector("_MoonColor", LunarColor);
        }
    }
}