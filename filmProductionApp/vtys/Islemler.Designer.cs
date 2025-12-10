namespace vtys
{
    partial class Islemler
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            dataGridView1 = new DataGridView();
            btnPuan = new Button();
            txtPuan = new TextBox();
            btnSeeReleases = new Button();
            txtId = new TextBox();
            btnFullFilm = new Button();
            txtPersonId = new TextBox();
            btnPersonId = new Button();
            ((System.ComponentModel.ISupportInitialize)dataGridView1).BeginInit();
            SuspendLayout();
            // 
            // dataGridView1
            // 
            dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dataGridView1.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dataGridView1.Location = new Point(31, 12);
            dataGridView1.Name = "dataGridView1";
            dataGridView1.RowHeadersWidth = 62;
            dataGridView1.Size = new Size(991, 483);
            dataGridView1.TabIndex = 0;
            // 
            // btnPuan
            // 
            btnPuan.Location = new Point(1255, 54);
            btnPuan.Name = "btnPuan";
            btnPuan.Size = new Size(372, 49);
            btnPuan.TabIndex = 1;
            btnPuan.Text = "dan yuksek puani olan filmleri gor";
            btnPuan.UseVisualStyleBackColor = true;
            btnPuan.Click += btnPuan_Click;
            // 
            // txtPuan
            // 
            txtPuan.Location = new Point(1135, 72);
            txtPuan.Name = "txtPuan";
            txtPuan.Size = new Size(97, 31);
            txtPuan.TabIndex = 2;
            // 
            // btnSeeReleases
            // 
            btnSeeReleases.Location = new Point(1357, 141);
            btnSeeReleases.Name = "btnSeeReleases";
            btnSeeReleases.Size = new Size(270, 51);
            btnSeeReleases.TabIndex = 3;
            btnSeeReleases.Text = "Id'li filmin yayinlarini gor";
            btnSeeReleases.UseVisualStyleBackColor = true;
            btnSeeReleases.Click += btnSeeReleases_Click;
            // 
            // txtId
            // 
            txtId.Location = new Point(1226, 221);
            txtId.Name = "txtId";
            txtId.Size = new Size(97, 31);
            txtId.TabIndex = 4;
            // 
            // btnFullFilm
            // 
            btnFullFilm.Location = new Point(1357, 198);
            btnFullFilm.Name = "btnFullFilm";
            btnFullFilm.Size = new Size(270, 54);
            btnFullFilm.TabIndex = 5;
            btnFullFilm.Text = "Id'li filmin bilgilerini gor";
            btnFullFilm.UseVisualStyleBackColor = true;
            btnFullFilm.Click += btnFullFilm_Click;
            // 
            // txtPersonId
            // 
            txtPersonId.Location = new Point(1255, 368);
            txtPersonId.Name = "txtPersonId";
            txtPersonId.Size = new Size(113, 31);
            txtPersonId.TabIndex = 6;
            // 
            // btnPersonId
            // 
            btnPersonId.Location = new Point(1404, 339);
            btnPersonId.Name = "btnPersonId";
            btnPersonId.Size = new Size(223, 60);
            btnPersonId.TabIndex = 7;
            btnPersonId.Text = "Id'li kişinin bilgilerini gor";
            btnPersonId.UseVisualStyleBackColor = true;
            btnPersonId.Click += btnPersonId_Click;
            // 
            // Islemler
            // 
            AutoScaleDimensions = new SizeF(10F, 25F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1698, 529);
            Controls.Add(btnPersonId);
            Controls.Add(txtPersonId);
            Controls.Add(btnFullFilm);
            Controls.Add(txtId);
            Controls.Add(btnSeeReleases);
            Controls.Add(txtPuan);
            Controls.Add(btnPuan);
            Controls.Add(dataGridView1);
            Name = "Islemler";
            Text = "Islemler";
            Load += Islemler_Load;
            ((System.ComponentModel.ISupportInitialize)dataGridView1).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private DataGridView dataGridView1;
        private Button btnPuan;
        private TextBox txtPuan;
        private Button btnSeeReleases;
        private TextBox txtId;
        private Button btnFullFilm;
        private TextBox txtPersonId;
        private Button btnPersonId;
    }
}