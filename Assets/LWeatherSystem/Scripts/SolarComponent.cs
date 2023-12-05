using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class SolarComponent : IComponent
{
    [Range(0f, 20f)]
    public float SunBloom = 8f;

    [Range(0f, 5f)]
    public float HorizontHaze = 4f;

    [Range(0, 10)]
    public float _SunRadius = 8f;

    private void LateUpdate()
    {
        if (m_skyboxController != null)
        {
            m_skyboxController.SkyboxMat.SetVector("_SunDir", -transform.forward);
            m_skyboxController.SkyboxMat.SetMatrix("_SunSpaceMatrix", transform.localToWorldMatrix);
            m_skyboxController.SkyboxMat.SetFloat("_SunBloom", SunBloom);
            m_skyboxController.SkyboxMat.SetFloat("_HorizonHaze", HorizontHaze);
            m_skyboxController.SkyboxMat.SetFloat("_SunRadius", _SunRadius);
        }
    }
}