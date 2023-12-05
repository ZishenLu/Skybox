using Unity.VisualScripting;
using UnityEngine;

[ExecuteAlways]
public class SkyboxController : MonoBehaviour
{
    [SerializeField] public Material SkyboxMat;
    [SerializeField] public Transform Solar;
    [Range(0f, 24f)] public float DailyTime;
    public float MidLux = 100000f;
    public float SunsetLux = 5000f;
    public float MoonLux = 0.5f;
    public float NightLux = 0.001f;
    private float m_Density;
    private float m_Lux;

    private void Update()
    {
        //DailyTime += Time.deltaTime / 30;
        //if (DailyTime >= 24) DailyTime = 0;
    }

    private void LateUpdate()
    {
        Solar.localRotation = Quaternion.Euler(DailyTime * 15 - 90, 0, 0);

        if (DailyTime < 2 || DailyTime > 22)
        {
            m_Density = 0.15f;
            m_Lux = NightLux;
        }
        else if (DailyTime < 6 || DailyTime > 18)
        {
            m_Density = 0.15f;
            m_Lux = MoonLux;
        }
        else if (DailyTime > 8 && DailyTime < 16)
        {
            m_Density = 0.8f;
            m_Lux = MidLux;
        }
        else
        {
            m_Density = Mathf.SmoothStep(0.4f, 0.8f, Mathf.Abs(DailyTime % 12 - 6) / 2);
            m_Lux = SunsetLux;
            //m_Lux = Mathf.SmoothStep(NightLux, SunsetLux, Mathf.Abs(DailyTime % 12 - 6) / 2);
        }
        GetComponentInChildren<CloudComponent>().Density = m_Density;
        var x = Mathf.Exp(-1 / m_Lux);
        GetComponentInChildren<CloudComponent>().Color = new Color(x, x, x, 1);
    }
}